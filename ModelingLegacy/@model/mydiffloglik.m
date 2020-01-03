function [MLL, score, info, se2] = mydiffloglik(this, data, likOpt, opt)
% mydiffloglik  Gradient and hessian of log-likelihood function
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;
EPSILON = eps( )^(1/3);

if ~isfield(opt, 'progress')
    opt.progress = false;
end

if ~isfield(opt, 'percent')
    opt.percent = false;
end

%--------------------------------------------------------------------------

posOfValues = this.Update.PosOfValues;
posOfStdCorr = this.Update.PosOfStdCorr;

ny = sum(this.Quantity.Type==TYPE(1));
numOfParams = length(posOfValues);
[~, numOfPeriods, numDataSets] = size(data);

MLL = zeros(1, numDataSets);
score = zeros(1, numOfParams, numDataSets);
info = zeros(numOfParams, numOfParams, numDataSets);
se2 = zeros(1, numDataSets);

p = nan(1, numOfParams);
indexNaNPosValues = isnan(posOfValues);
indexNaNPosStdCorr = isnan(posOfStdCorr);
p(~indexNaNPosValues) = this.Variant.Values(:, posOfValues(~indexNaNPosValues), :);
p(~indexNaNPosStdCorr) = this.Variant.StdCorr(1, posOfStdCorr(~indexNaNPosStdCorr), :);

step = EPSILON * max([abs(p); ones(size(p))], [ ], 1);
twoSteps = nan(1, numOfParams);

throwErr = true;

% Create all parameterisations.
this = alter(this, 2*numOfParams+1);
for i = 1 : numOfParams
    pp = p;
    mp = p;
    pp(i) = pp(i) + step(i);
    mp(i) = mp(i) - step(i);
    twoSteps(i) = pp(i) - mp(i);
    variantRequested = 1 + 2*(i-1) + 1;
    this = update(this, pp, variantRequested);
    variantRequested = 1 + 2*(i-1) + 2;
    this = update(this, mp, variantRequested);
end

% Horizontal vectorisation.
vechor = @(x) x(:)';

if opt.progress
    % Create progress bar.
    progress = ProgressBar('IRIS model.diffloglik progress');
end

for iData = 1 : numDataSets
    mainLoop( );
end

return


    function mainLoop( )        
        dpe = cell(1, numOfParams);
        dpe(:) = {nan(ny, numOfPeriods)};
        
        Fi_pe = zeros(ny, numOfPeriods);
        X = zeros(ny);
        
        Fi_dpe = cell(1, numOfParams);
        Fi_dpe(1:numOfParams) = {nan(ny, numOfPeriods)};
        
        dF = cell(1, numOfParams);
        dF(:) = {nan(ny, ny, numOfPeriods)};
        
        dFvec = cell(1, numOfParams);
        dFvec(:) = {[ ]};
        
        Fi_dF = cell(1, numOfParams);
        Fi_dF(:) = {nan(ny, ny, numOfPeriods)};

        % Call the Kalman filter.
        temp = getVariant(this, 1);
        [MLL(iData), Y] = kalmanFilter(temp, data(:, :, iData), [ ], [ ], likOpt);        
        se2(iData) = Y.V;
        F = Y.F(:, :, 2:end);
        pe = Y.Pe(:, 2:end);
        Fi = F;
        for ii = 1 : size(Fi, 3)
            j = ~all(isnan(Fi(:, :, ii)), 1);
            Fi(j, j, ii) = inv(Fi(j, j, ii));
        end
        
        for ii = 1 : numOfParams
            pm = getVariant(this, 1+2*(ii-1)+1);
            [~, Y] = kalmanFilter(pm, data(:, :, iData), [ ], [ ], likOpt);
            pF =  Y.F(:, :, 2:end);
            ppe = Y.Pe(:, 2:end);
            
            mm = getVariant(this, 1+2*(ii-1)+2);
            [~, Y] = kalmanFilter(mm, data(:, :, iData), [ ], [ ], likOpt);
            mF =  Y.F(:, :, 2:end);
            mpe = Y.Pe(:, 2:end);
            
            dF{ii}(:, :, :) = (pF - mF) / twoSteps(ii);
            dpe{ii}(:, :) = (ppe - mpe) / twoSteps(ii);
        end
        
        for t = 1 : numOfPeriods
            o = ~isnan(pe(:, t));
            for ii = 1 : numOfParams
                Fi_dF{ii}(o, o, t) = Fi(o, o, t)*dF{ii}(o, o, t);
            end
        end
        
        for t = 1 : numOfPeriods
            o = ~isnan(pe(:, t));
            for ii = 1 : numOfParams
                temp = dF{ii}(o, o, t);
                dFvec{t}(:, ii) = temp(:);
                for jj = 1 : ii
                    % Info(i, j, idata) =  ...
                    %     Info(i, j, idata) ...
                    %     + 0.5*trace(Fi_dF{i}(o, o, t)*Fi_dF{j}(o, o, t)) ...
                    %     + (transpose(dpe{i}(o, t))*Fi_dpe{j}(o, t));
                    % * the first term is data independent
                    % * trace A*B = vechor(A')*vec(B)
                    Xi = transpose(Fi_dF{ii}(o, o, t));
                    Xi = transpose(Xi(:));
                    Xj = Fi_dF{jj}(o, o, t);
                    Xj = Xj(:);
                    info(ii, jj, iData) = info(ii, jj, iData) + Xi*Xj/2;
                end
            end
        end
        
        % Score vector.
        for t = 1 : numOfPeriods
            o = ~isnan(pe(:, t));
            Fi_pe(o, t) = Fi(o, o, t)*pe(o, t);
            X(o, o, t) = eye(sum(o)) - Fi_pe(o, t)*transpose(pe(o, t));
            dpevec = [ ];
            for ii = 1 : numOfParams
                dpevec = [dpevec, dpe{ii}(o, t)]; %#ok<AGROW>
                Fi_dpe{ii}(o, t) = Fi(o, o, t)*dpe{ii}(o, t);
            end
            score(1, :, iData) = score(1, :, iData) ...
                + vechor(Fi(o, o, t)*transpose(X(o, o, t)))*dFvec{t}/2 ...
                + transpose(Fi_pe(o, t))*dpevec;
        end
        
        % Information matrix.
        for t = 1 : numOfPeriods
            o = ~isnan(pe(:, t));
            for ii = 1 : numOfParams
                for jj = 1 : ii
                    % Info(i, j, idata) =
                    %     Info(i, j, idata)
                    %     + 0.5*trace(Fi_dF{i}(o, o, t)*Fi_dF{j}(o, o, t))
                    %     + (transpose(dpe{i}(o, t))*Fi_dpe{j}(o, t));
                    % first term is data-independent and has been pre-computed.
                    info(ii, jj, iData) = info(ii, jj, iData) ...
                        + (transpose(dpe{ii}(o, t))*Fi_dpe{jj}(o, t));
                end
            end
        end
        
        info(:, :, iData) = info(:, :, iData) + transpose(tril(info(:, :, iData), -1));
        
        if opt.progress
            % Update progress bar.
            update(progress, iData/numDataSets);
        end
    end
end
