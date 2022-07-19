% mydiffloglik  Gradient and hessian of log-likelihood function
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [MLL, score, info, se2] = mydiffloglik(this, data, likOpt, opt)

EPSILON = eps()^(1/3);

vecv = @(x) reshape(x, [ ], 1);
vech = @(x) reshape(x, 1, [ ]);


if ~isfield(opt, 'Progress')
    opt.Progress = false;
end

if ~isfield(opt, 'percent')
    opt.percent = false;
end

%--------------------------------------------------------------------------

posValues = this.Update.PosOfValues;
posStdCorr = this.Update.PosOfStdCorr;

%
% Switch betwen measurement variables versus transition variables marked
% for measurement
%
[ny, ~, ~, ~, ~, ~, nz] = sizeSolution(this);
if ny==0 && nz>0
    ny = nz;
end

numParams = length(posValues);
[~, numPeriods, numDataSets] = size(data);

MLL = zeros(1, numDataSets);
score = zeros(1, numParams, numDataSets);
info = zeros(numParams, numParams, numDataSets);
se2 = zeros(1, numDataSets);

p = nan(1, numParams);
indexNaNPosValues = isnan(posValues);
indexNaNPosStdCorr = isnan(posStdCorr);
p(~indexNaNPosValues) = this.Variant.Values(:, posValues(~indexNaNPosValues), :);
p(~indexNaNPosStdCorr) = this.Variant.StdCorr(1, posStdCorr(~indexNaNPosStdCorr), :);

step = EPSILON * max([abs(p); ones(size(p))], [ ], 1);
twoSteps = nan(1, numParams);

throwErr = true;

% Create all parameterisations.
this = alter(this, 2*numParams+1);
for i = 1 : numParams
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

if opt.Progress
    % Create progress bar
    progress = ProgressBar('[IrisToolbox] @Model/diffloglik Progress');
end

kalmanFilterInput = struct();
kalmanFilterInput.InputData = [ ];
kalmanFilterInput.OutputData = [ ];
kalmanFilterInput.InternalAssignFunc = [ ];
kalmanFilterInput.Options = likOpt;
kalmanFilterInput.FilterRange = NaN;

for iData = 1 : numDataSets
    mainLoop();
end

return


    function mainLoop()
        dpe = cell(1, numParams);
        dpe(:) = {nan(ny, numPeriods)};

        Fi_pe = zeros(ny, numPeriods);
        X = zeros(ny);

        Fi_dpe = cell(1, numParams);
        Fi_dpe(1:numParams) = {nan(ny, numPeriods)};

        dF = cell(1, numParams);
        dF(:) = {nan(ny, ny, numPeriods)};

        dFvec = cell(1, numParams);
        dFvec(:) = {[ ]};

        Fi_dF = cell(1, numParams);
        Fi_dF(:) = {nan(ny, ny, numPeriods)};

        % Call the Kalman filter
        kalmanFilterInput.InputData = data(:, :, iData);
        [MLL(iData), Y] = implementKalmanFilter(getVariant(this, 1), kalmanFilterInput);
        se2(iData) = Y.V;
        F = Y.F(:, :, 2:end);
        pe = Y.Pe(:, 2:end);
        Fi = F;
        for ii = 1 : size(Fi, 3)
            j = ~all(isnan(Fi(:, :, ii)), 1);
            Fi(j, j, ii) = inv(Fi(j, j, ii));
        end

        for ii = 1 : numParams
            pm = getVariant(this, 1+2*(ii-1)+1);
            [~, Y] = implementKalmanFilter(pm, kalmanFilterInput);
            pF =  Y.F(:, :, 2:end);
            ppe = Y.Pe(:, 2:end);

            mm = getVariant(this, 1+2*(ii-1)+2);
            [~, Y] = implementKalmanFilter(mm, kalmanFilterInput);
            mF =  Y.F(:, :, 2:end);
            mpe = Y.Pe(:, 2:end);

            dF{ii}(:, :, :) = (pF - mF) / twoSteps(ii);
            dpe{ii}(:, :) = (ppe - mpe) / twoSteps(ii);
        end

        for t = 1 : numPeriods
            o = ~isnan(pe(:, t));
            for ii = 1 : numParams
                Fi_dF{ii}(o, o, t) = Fi(o, o, t)*dF{ii}(o, o, t);
            end
        end

        for t = 1 : numPeriods
            o = ~isnan(pe(:, t));
            for ii = 1 : numParams
                dFvec{t}(:, ii) = vecv(dF{ii}(o, o, t));
                for jj = 1 : ii
                    % Info(i, j, idata) =  ...
                    %     Info(i, j, idata) ...
                    %     + 0.5*trace(Fi_dF{i}(o, o, t)*Fi_dF{j}(o, o, t)) ...
                    %     + (transpose(dpe{i}(o, t))*Fi_dpe{j}(o, t));
                    % * the first term is data independent
                    % * trace A*B = vech(A')*vec(B)
                    Xi = transpose(Fi_dF{ii}(o, o, t));
                    Xi = vech(Xi);
                    Xj = Fi_dF{jj}(o, o, t);
                    Xj = vecv(Xj);
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
            for ii = 1 : numParams
                dpevec = [dpevec, dpe{ii}(o, t)]; %#ok<AGROW>
                Fi_dpe{ii}(o, t) = Fi(o, o, t)*dpe{ii}(o, t);
            end
            score(1, :, iData) = score(1, :, iData) ...
                + vech(Fi(o, o, t)*transpose(X(o, o, t)))*dFvec{t}/2 ...
                + transpose(Fi_pe(o, t))*dpevec;
        end

        % Information matrix.
        for t = 1 : numPeriods
            o = ~isnan(pe(:, t));
            for ii = 1 : numParams
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

        if opt.Progress
            % Update progress bar.
            update(progress, iData/numDataSets);
        end
    end
end%

