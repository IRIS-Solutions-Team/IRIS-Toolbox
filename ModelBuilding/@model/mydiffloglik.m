function [MLL, score, info, se2] = mydiffloglik(this, data, likOpt, opt)
% mydiffloglik  Gradient and hessian of log-likelihood function.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;
EPSILON = eps( )^(1/3);

if ~isfield(opt, 'progress')
    opt.progress = false;
end

if ~isfield(opt, 'percent')
    opt.percent = false;
end

% Initialise steady-state solver and chksstate options.
opt.Steady = prepareSteady(this, 'silent', opt.Steady);
opt.ChkSstate = prepareChkSteady(this, 'silent', opt.ChkSstate);
opt.Solve = prepareSolve(this, 'silent, fast', opt.Solve);

%--------------------------------------------------------------------------

posValues = this.TaskSpecific.Update.PosValues;
posStdCorr = this.TaskSpecific.Update.PosStdCorr;

ny = sum(this.Quantity.Type==TYPE(1));
numParameters = length(posValues);
[~, numPeriods, numDataSets] = size(data);

MLL = zeros(1, numDataSets);
score = zeros(1, numParameters, numDataSets);
info = zeros(numParameters, numParameters, numDataSets);
se2 = zeros(1, numDataSets);

p = nan(1, numParameters);
indexNaNPosValues = isnan(posValues);
indexNaNPosStdCorr = isnan(posStdCorr);
p(~indexNaNPosValues) = this.Variant.Values(:, posValues(~indexNaNPosValues), :);
p(~indexNaNPosStdCorr) = this.Variant.StdCorr(1, posStdCorr(~indexNaNPosStdCorr), :);

step = EPSILON * max([abs(p); ones(size(p))], [ ], 1);
twoSteps = nan(1, numParameters);

throwErr = true;

% Create all parameterisations.
this(1:2*numParameters+1) = this;
for i = 1 : numParameters
    pp = p;
    mp = p;
    pp(i) = pp(i) + step(i);
    mp(i) = mp(i) - step(i);
    twoSteps(i) = pp(i) - mp(i);
    ix = 1 + 2*(i-1) + 1;
    this(ix) = update(this(ix), pp, 1, opt, throwErr);
    ix = 1 + 2*(i-1) + 2;
    this(ix) = update(this(ix), mp, 1, opt, throwErr);
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
        dpe = cell(1, numParameters);
        dpe(:) = {nan(ny, numPeriods)};
        
        Fi_pe = zeros(ny, numPeriods);
        X = zeros(ny);
        
        Fi_dpe = cell(1, numParameters);
        Fi_dpe(1:numParameters) = {nan(ny, numPeriods)};
        
        dF = cell(1, numParameters);
        dF(:) = {nan(ny, ny, numPeriods)};
        
        dFvec = cell(1, numParameters);
        dFvec(:) = {[ ]};
        
        Fi_dF = cell(1, numParameters);
        Fi_dF(:) = {nan(ny, ny, numPeriods)};

        % Call the Kalman filter.
        [MLL(iData), Y] = kalmanFilter(this(1), data(:, :, iData), [ ], likOpt);        
        se2(iData) = Y.V;
        F = Y.F(:, :, 2:end);
        pe = Y.Pe(:, 2:end);
        Fi = F;
        for ii = 1 : size(Fi, 3)
            j = ~all(isnan(Fi(:, :, ii)), 1);
            Fi(j, j, ii) = inv(Fi(j, j, ii));
        end
        
        for ii = 1 : numParameters
            pm = this(1+2*(ii-1)+1);
            [~, Y] = kalmanFilter(pm, data(:, :, iData), [ ], likOpt);
            pF =  Y.F(:, :, 2:end);
            ppe = Y.Pe(:, 2:end);
            
            mm = this(1+2*(ii-1)+2);
            [~, Y] = kalmanFilter(mm, data(:, :, iData), [ ], likOpt);
            mF =  Y.F(:, :, 2:end);
            mpe = Y.Pe(:, 2:end);
            
            dF{ii}(:, :, :) = (pF - mF) / twoSteps(ii);
            dpe{ii}(:, :) = (ppe - mpe) / twoSteps(ii);
        end
        
        for t = 1 : numPeriods
            o = ~isnan(pe(:, t));
            for ii = 1 : numParameters
                Fi_dF{ii}(o, o, t) = Fi(o, o, t)*dF{ii}(o, o, t);
            end
        end
        
        for t = 1 : numPeriods
            o = ~isnan(pe(:, t));
            for ii = 1 : numParameters
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
        for t = 1 : numPeriods
            o = ~isnan(pe(:, t));
            Fi_pe(o, t) = Fi(o, o, t)*pe(o, t);
            X(o, o, t) = eye(sum(o)) - Fi_pe(o, t)*transpose(pe(o, t));
            dpevec = [ ];
            for ii = 1 : numParameters
                dpevec = [dpevec, dpe{ii}(o, t)]; %#ok<AGROW>
                Fi_dpe{ii}(o, t) = Fi(o, o, t)*dpe{ii}(o, t);
            end
            score(1, :, iData) = score(1, :, iData) ...
                + vechor(Fi(o, o, t)*transpose(X(o, o, t)))*dFvec{t}/2 ...
                + transpose(Fi_pe(o, t))*dpevec;
        end
        
        % Information matrix.
        for t = 1 : numPeriods
            o = ~isnan(pe(:, t));
            for ii = 1 : numParameters
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
