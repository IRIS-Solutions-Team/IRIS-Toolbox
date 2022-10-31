% implementKalmanFilter  Kalman filter
%
% This Kalman filter handles the following special cases:
%
% * non-stationary initial conditions
%
% * measurement parameters concentrated out of likelihood;
%
% * time-varying std deviations;
%
% * conditioning of likelihood upon some measurement variables;
%
% * exclusion of some of the periods from likelihood;
%
% * k-step-ahead predictions;
%
% * tunes on the mean of shocks, combined anticipated and unanticipated;
%
% * missing observations entered as NaNs;
%
% * infinite std devs of measurement shocks equivalent to missing obs.
%
% * contributions of measurement variables to transition variables.
%

function [obj, regOutp, outputData] = implementKalmanFilter(this, argin)

    inputData = argin.InputData;
    outputData = argin.OutputData;
    outputDataAssignFunc = argin.InternalAssignFunc;
    opt = argin.Options;


    if ~isfield(opt, 'Initials') && isfield(opt, 'Init')
        opt.Initials = opt.Init;
    end


    % range = double(argin.FilterRange);
    % initials = {};
    % timeVarying = [];
    % [timeVarying, initials] = prepareLinearSystem( ...
    %     this, range, opt.Override, opt.Multiply, 1, true ...
    %     , opt.Steady, opt.CheckSteady, opt.Solve ...
    % );
    % if ~isempty(timeVarying)
    %     opt.Override = [];
    %     opt.Multiply = [];
    %     this = timeVarying;
    % end

    [ny, nxi, nb, nf, ne, ng, nz] = sizeSolution(this);
    nv = countVariants(this);

    % Transition variables marked as observables
    if nz>0
        ny = nz;
    end

    % Add one presample period to data
    numPages = size(inputData, 3);
    inputData = [nan(size(inputData, 1), 1, numPages), inputData];
    numExtendedPeriods = size(inputData, 2);

    %--------------------------------------------------------------------------

    s = struct();
    s.MEASUREMENT_MATRIX_TOLERANCE = this.MEASUREMENT_MATRIX_TOLERANCE;
    s.DIFFUSE_SCALE = opt.DiffuseScale;
    s.OBJ_FUNC_PENALTY = this.OBJ_FUNC_PENALTY;

    s.Ahead = opt.Ahead;
    s.IsObjOnly = nargout<=1;
    s.NumExtdPeriods = numExtendedPeriods;
    s.NumY  = ny;
    s.NumXi = nxi;
    s.NumB  = nb;
    s.NumF  = nf;
    s.NumE  = ne;
    s.NumG  = ng;

    s.NeedsSimulate = ~isequal(opt.Simulate, false);

    % Out-of-lik params cannot be used with ~opt.EvalTrends
    numOutlik = length(opt.Outlik);

    % Struct with currently processed information. Initialise the invariant
    % fields
    s.ny = ny;
    s.nb = nb;
    s.nf = nf;
    s.ne = ne;
    s.NumOutlik = numOutlik;

    % Add pre-sample to objective function range and deterministic time trend
    s.InxObjFunc = [false, opt.ObjFuncRange];

    % Do not adjust the option `'lastSmooth='` -- see comments in `loglikopt`
    s.LastSmooth = opt.LastSmooth;

    % Override shock means
    overrideMean = opt.OverrideMean;
    mayberOverrideMean = ~isempty(overrideMean) && ~all(overrideMean(:)==0 | isnan(overrideMean(:)));
    requiredForward = 0;
    if mayberOverrideMean
        overrideMean(isnan(overrideMean)) = 0;
        % Add pre-sample
        overrideMean = [zeros(ne, 1, size(overrideMean, 3)), overrideMean];
        % Split into anticipated and unanticipated
        overrideMeanAnticipated = opt.AnticipatedFunc(overrideMean);
        overrideMeanUnanticipated = opt.UnanticipatedFunc(overrideMean);
        overrideMeanAnticipated(isnan(overrideMeanAnticipated)) = 0;
        overrideMeanUnanticipated(isnan(overrideMeanUnanticipated)) = 0;
        % Anticipated shocks and forward expansion
        inx = any(any(overrideMeanAnticipated~=0, 3), 1);
        requiredForward = max([0, find(inx, 1, 'last')]) - 2;
    end

    % Total number of runs
    numRuns = max(numPages, nv);
    s.nPred = max(numRuns, s.Ahead);

    % Pre-allocate output data
    if ~s.IsObjOnly
        requestOutp();
    end

    % Pre-allocate the non-hdata output arguments
    nObj = 1;
    if opt.ReturnObjFuncContribs
        nObj = numExtendedPeriods;
    end
    obj = nan(nObj, numRuns);


    if ~s.IsObjOnly
        % Regular (non-hdata) output arguments
        regOutp = struct();
        regOutp.F = nan(ny, ny, numExtendedPeriods, numRuns);
        regOutp.Pe = nan(ny, numExtendedPeriods, s.nPred);
        regOutp.V = nan(1, numRuns);
        regOutp.Delta = nan(numOutlik, numRuns);
        regOutp.PDelta = nan(numOutlik, numOutlik, numRuns);
        regOutp.SampleCov = nan(ne, ne, numRuns);
        regOutp.NLoop = numRuns;
        regOutp.Initials = { nan(nb, 1, numRuns), nan(nb, nb, numRuns), zeros(nb, nb, numRuns) };
        regOutp.U = cell(1, nv);
    end

    %
    % Main loop
    %

    if ~s.IsObjOnly && opt.Progress
        progress = ProgressBar('[IrisToolbox] Kalman.implementKalmanFilter');
    end

    inxSolutionAvailable = true(1, nv);
    inxValidFactor = true(1, numRuns);



    %=========================================================================
    for run = 1 : numRuns
        if s.NeedsSimulate
            prepareOnly = true;
            s.Simulate = simulateFrames(this, opt.Simulate, run, prepareOnly);
        end

        %
        % Next data
        % Measurement and exogenous variables, and initial observations of
        % measurement variables. Deterministic trends will be subtracted later on.
        %
        s.y1 = inputData(1:ny, :, min(run, end));
        s.g  = inputData(ny+(1:ng), :, min(run, end));

        s.IsOverrideMean = false;
        if mayberOverrideMean
            s.OverrideMean = overrideMean(:, :, min(run, end));
            s.VaryingU = overrideMeanUnanticipated(:, :, min(run, end));
            s.VaryingE = overrideMeanAnticipated(:, :, min(run, end));
            s.LastVaryingU = max([0, find(any(s.VaryingU, 1), 1, 'last')]);
            s.LastVaryingE = max([0, find(any(s.VaryingE, 1), 1, 'last')]);
            s.IsOverrideMean = s.LastVaryingU>0 || s.LastVaryingE>0;
        end

        %
        % Next model solution
        %
        v = min(run, nv);
        if run<=nv
            %
            % Get the v-th Kalman system
            %
            [ ...
                T, R, k, s.Z, s.H, d, s.U, Zb, ...
                s.InxV, s.InxW, s.NumUnitRoots, s.InxInit ...
            ] = getIthKalmanSystem(this, v, requiredForward);

            %
            % Transition variables marked for measurement
            %
            if nz>0
                if isempty(s.U)
                    s.Z = Zb;
                else
                    numZ = max(size(Zb, 3), size(s.U, 3));
                    s.Z = nan(ny, nb, numZ);
                    for ii = 1 : numZ
                        s.Z(:, :, ii) = Zb(:, :, min(ii, end))*s.U(:, :, min(ii, end));
                    end
                end
                s.H = zeros(nz, ne);
                s.d = zeros(nz, 1);
            end

            s.Tf = T(1:nf, :, :);
            s.Ta = T(nf+1:end, :, :);

            % Keep forward expansion for computing the effect of tunes on shock
            % means. Cut off the expansion within subfunctions.
            s.Rf = R(1:nf, 1:ne, :);
            s.Ra = R(nf+1:end, 1:ne, :);
            if opt.Deviation
                s.ka = [];
                s.kf = [];
                s.d  = [];
            else
                s.kf = k(1:nf, :);
                s.ka = k(nf+1:end, :);
                s.d  = d(:, :);
            end

            s = here_getReducedFormCovariance(this, v, s, opt);
        end

        % Stop immediately if solution is not available; report NaN solutions
        % post mortem
        inxSolutionAvailable(run) = all(isfinite(T(:)));
        if ~inxSolutionAvailable(run)
            continue
        end


        %
        % Measurement trends
        %
        % y(t) - D(t) - X(t)*delta = Z*a(t) + H*e(t).
        %
        if nz==0 && (numOutlik>0 || opt.EvalTrends)
            [s.D, s.X] = evalTrendEquations(this, opt.Outlik, s.g, run);
        else
            s.D = [];
            s.X = zeros(ny, 0, numExtendedPeriods);
        end
        % Subtract fixed deterministic trends from measurement variables
        if ~isempty(s.D)
            s.y1 = s.y1 - s.D;
        end


        % __Next Tunes on the Means of the Shocks__
        % Add the effect of the tunes to the constant vector; recompute the
        % effect whenever the tunes have changed or the model solution has changed
        % or both.
        %
        % The std dev of the tuned shocks remain unchanged and hence the
        % filtered shocks can differ from its tunes (unless the user specifies zero
        % std dev).
        if s.IsOverrideMean
            [s.d, s.ka, s.kf] = here_overrideMean(s, R, opt);
        end

        % Index of available observations.
        s.yindex = ~isnan(s.y1);
        s.LastObs = max([ 0, find( any(s.yindex, 1), 1, 'last' ) ]);
        s.jyeq = [false, all(s.yindex(:, 2:end)==s.yindex(:, 1:end-1), 1) ];


        %
        % Initialize mean and MSE
        % Determine number of init cond estimated as fixed unknowns
        %
        % if ~isempty(initials)
        %     s.InitMean = initials{1};
        %     s.InitMseReg = initials{2};
        %     s.InitMseInf = initials{3};
        %     s.NumEstimInit = initials{4};
        % else
            if iscell(opt.Initials)
                init__ = cell(size(opt.Initials));
                for i = 1 : numel(init__)
                    init__{i} = double(opt.Initials{i}(:, :, min(end, run)));
                end
            else
                init__ = opt.Initials;
            end
            if isnumeric(opt.UnitRootInitials)
                initUnit__ = double(opt.UnitRootInitials(:, :, min(end, run)));
            else
                initUnit__ = opt.UnitRootInitials;
            end
            if isfield(opt, 'Preiterate')
                preiterate__ = opt.Preiterate(min(end, run));
            else
                preiterate__ = 0;
            end
            s = iris.mixin.Kalman.initialize(s, init__, initUnit__, preiterate__);
        % end

        %
        % Prediction step
        %

        % Run prediction error decomposition and evaluate user-requested
        % objective function.
        [obj(:, run), s] = iris.mixin.Kalman.predictErrorDecomposition(s, opt);
        inxValidFactor(run) = abs(s.V)>this.VARIANCE_FACTOR_TOLERANCE;

        % Return immediately if only the value of the objective function is
        % requested.
        if s.IsObjOnly
            continue
        end

        % Prediction errors unadjusted (uncorrected) for estimated init cond
        % and DTrends; these are needed for contributions.
        if s.returnContribs
            s.peUnc = s.pe;
        end

        % Correct prediction errors for estimated initial conditions and DTrends
        % parameters.
        if s.NumEstimInit>0 || numOutlik>0
            est = [s.delta; s.init];
            if s.storePredict
                [s.pe, s.a0, s.y0, s.ydelta] = iris.mixin.Kalman.correct(s, s.pe, s.a0, s.y0, est, s.d);
            else
                s.pe = iris.mixin.Kalman.correct(s, s.pe, [], [], est, []);
            end
        end


        %
        % Add k-step-ahead predictions for alpha
        %
        if s.Ahead>1 && s.storePredict
            s = here_ahead(s);
        end


        % Prediction step for xif and xib
        if s.retPredMse || s.retPredStd || s.retFilter || s.retSmooth
            s = here_predictXifMse(s);
        end
        if s.retPred || s.retFilter || s.retSmooth
            % Predictions for xif have been already filled in in non-linear predictions
            if ~s.NeedsSimulate
                s = here_getPredXfMean(s);
            end
            % Predictions for xib
            s = here_predictXibMean(s);
        end


        %
        % Updating step
        %
        if s.retFilter
            if s.retFilterStd || s.retFilterMse
                s = here_getUpdateMse(s);
            end
            s = here_getUpdateMean(s);
        end


        %
        % Smoother
        %
        if s.retSmooth
            if s.retSmoothStd || s.retSmoothMse
                s = here_getSmoothMse(s);
            end
            s = here_getSmoothMean(s);
        end


        %
        % Contributions of measurement variables
        %
        if s.returnContribs
            s = iris.mixin.Kalman.contributions(s);
        end


        %
        % Return Requested Data
        % Columns in `pe` to be filled.
        %
        if s.Ahead>1
            predCols = 1 : s.Ahead;
        else
            predCols = run;
        end

        %
        % Populate hdata output arguments
        %
        if s.retPred
            here_returnPred();
        end
        if s.retFilter
            returnUpdate();
        end
        s.SampleCov = NaN;
        if s.retSmooth
            here_returnSmooth();
        end

        %
        % Populate regular (non-hdata) output arguments
        %
        regOutp.F(:, :, :, run) = s.F*s.V;
        regOutp.Pe(:, :, predCols) = permute(s.pe, [1, 3, 4, 2]);
        regOutp.V(run) = s.V;
        regOutp.Delta(:, run) = s.delta;
        regOutp.PDelta(:, :, run) = s.PDelta*s.V;
        regOutp.SampleCov(:, :, run) = s.SampleCov;
        regOutp.Initials{1}(:, :, run) = s.InitMean;
        regOutp.Initials{2}(:, :, run) = s.InitMseReg;
        regOutp.U{run} = s.U;
        if ~isempty(s.InitMseInf)
            regOutp.Initials{3}(:, :, run) = s.InitMseInf;
        end


        %
        % Update progress bar
        %
        if opt.Progress
            update(progress, run/numRuns);
        end
    end
    %=========================================================================

    if opt.ReturnObjFuncContribs
        obj = obj(2:end, :);
    end

    if ~all(inxSolutionAvailable)
        thisWarning = { 'Kalman:SystemMatricesWithNaN'
                        'Some of the Kalman system matrices are NaNs in %s' };
        throw( exception.Base(thisWarning, 'warning'), ...
               exception.Base.alt2str(~inxSolutionAvailable) ); %#ok<GTARG>
    end

    if any(~inxValidFactor)
        thisWarning = { 'Kalman:ZeroVarianceFactors'
                        'Variance-covariance scale factor is ill-determined in %s '};
        throw( exception.Base(thisWarning, 'warning'), ...
               exception.Base.alt2str(~inxValidFactor) ); %#ok<GTARG>
    end

return




    function requestOutp()
        s.retPredMean = isfield(outputData, 'M0');
        s.retPredMse = isfield(outputData, 'Mse0');
        s.retPredStd = isfield(outputData, 'S0');
        s.retPredCont = isfield(outputData, 'C0');
        s.retFilterMean = isfield(outputData, 'M1');
        s.retFilterMse = isfield(outputData, 'Mse1');
        s.retFilterStd = isfield(outputData, 'S1');
        s.retFilterCont = isfield(outputData, 'C1');
        s.retSmoothMean = isfield(outputData, 'M2');
        s.retSmoothMse = isfield(outputData, 'Mse2');
        s.retSmoothStd = isfield(outputData, 'S2');
        s.retSmoothCont = isfield(outputData, 'C2');
        s.retPred = s.retPredMean || s.retPredStd || s.retPredMse;
        s.retFilter = s.retFilterMean || s.retFilterStd || s.retFilterMse;
        s.retSmooth = s.retSmoothMean || s.retSmoothStd || s.retSmoothMse;
        s.returnContribs = s.retPredCont || s.retFilterCont || s.retSmoothCont;
        s.storePredict = s.Ahead>1 || s.retPred || s.retFilter || s.retSmooth;
    end%




    function here_returnPred()
        % Return pred mean.
        % Note that s.y0, s.f0 and s.a0 include k-sted-ahead predictions if
        % ahead>1.
        if s.retPredMean
            if nz>0
                s.y0 = s.y0([], :, :, :);
            end
            yy = permute(s.y0, [1, 3, 4, 2]);
            yy(:, 1, :) = NaN;
            if ~isempty(s.D)
                yy = yy + repmat(s.D, 1, 1, s.Ahead);
            end
            % Convert `alpha` predictions to `xb` predictions. The
            % `a0` may contain k-step-ahead predictions in 3rd dimension.
            b0 = permute(s.a0, [1, 3, 4, 2]);
            if ~isempty(s.U)
                if size(s.U, 3)==1
                    for ii = 1 : size(b0, 3)
                        b0(:, :, ii) = s.U*b0(:, :, ii);
                    end
                else
                    for tt = 2 : s.NumExtdPeriods
                        U = s.U(:, :, min(tt, end));
                        for ii = 1 : size(b0, 3)
                            b0(:, tt, ii) = U*b0(:, tt, ii);
                        end
                    end
                end
            end
            s.b0 = b0;
            ff = permute(s.f0, [1, 3, 4, 2]);
            xx = [ff; b0];
            % Shock predictions are always zeros.
            ee = zeros(ne, numExtendedPeriods, s.Ahead);
            % Set predictions for the pre-sample period to `NaN`.
            %=== xx(:, 1, :) = NaN;
            %=== ee(:, 1, :) = NaN;
            % Add fixed deterministic trends back to measurement vars.
            % Add shock tunes to shocks.
            if s.IsOverrideMean
                ee = ee + repmat(s.OverrideMean, 1, 1, s.Ahead);
            end
            % Do not use lags in the prediction output data.
            outputData.M0 = outputDataAssignFunc(outputData.M0, predCols, {yy, xx, ee, [], []});
        end

        % Return pred std
        if s.retPredStd
            if nz>0
                s.Dy0 = s.Dy0([], :);
            end
            % Do not use lags in the prediction output data
            outputData.S0 = outputDataAssignFunc( ...
                outputData.S0, run, ...
                {s.Dy0*s.V, [s.Df0; s.Db0]*s.V, s.De0*s.V, [], []} ...
            );
        end

        % Return prediction MSE for xb.
        if s.retPredMse
            outputData.Mse0.Data(:, :, :, run) = s.Pb0*s.V;
        end

        % Return PE contributions to prediction step.
        if s.retPredCont
            if nz>0
                s.yc0 = s.yc0([], :, :, :);
            end
            yy = s.yc0;
            yy = permute(yy, [1, 3, 2, 4]);
            xx = [s.fc0;s.bc0];
            xx = permute(xx, [1, 3, 2, 4]);
            xx(:, 1, :) = NaN;
            ee = s.ec0;
            ee = permute(ee, [1, 3, 2, 4]);
            outputData.C0 = outputDataAssignFunc(outputData.C0, ':', {yy, xx, ee, [], []});
        end
    end%




    function returnUpdate()
        if s.retFilterMean
            if nz>0
                s.y1 = s.y1([], :);
            end
            yy = s.y1;
            % Add fixed deterministic trends back to measurement vars.
            if ~isempty(s.D)
                yy = yy + s.D;
            end
            xx = [s.f1; s.b1];
            ee = s.e1;
            % Add shock tunes to shocks.
            if s.IsOverrideMean
                ee = ee + s.OverrideMean;
            end
            % Do not use lags in the filter output data.
            outputData.M1 = outputDataAssignFunc(outputData.M1, run, {yy, xx, ee, [], s.g});
        end

        % Return PE contributions to filter step.
        if s.retFilterCont
            if nz>0
                s.yc1 = s.yc1([], :, :, :);
            end
            yy = s.yc1;
            yy = permute(yy, [1, 3, 2, 4]);
            xx = [s.fc1; s.bc1];
            xx = permute(xx, [1, 3, 2, 4]);
            ee = s.ec1;
            ee = permute(ee, [1, 3, 2, 4]);
            outputData.C1 = outputDataAssignFunc(outputData.C1, ':', {yy, xx, ee, [], []});
        end

        % Return filter std.
        if s.retFilterStd
            if nz>0
                s.Dy1 = s.Dy1([], :);
            end
            outputData.S1 = outputDataAssignFunc( ...
                outputData.S1, run, ...
                {s.Dy1*s.V, [s.Df1;s.Db1]*s.V, [], [], s.Dg1*s.V} ...
            );
        end

        % Return filtered MSE for `xb`.
        if s.retFilterMse
            %s.Pb1(:, :, 1) = NaN;
            outputData.Mse1.Data(:, :, :, run) = s.Pb1*s.V;
        end
    end%




    function here_returnSmooth()
        if s.retSmoothMean
            if nz>0
                s.y2 = s.y2([], :);
            end
            yy = s.y2;
            yy(:, 1:s.LastSmooth) = NaN;
            % Add deterministic trends to measurement vars
            if ~isempty(s.D)
                yy = yy + s.D;
            end
            xx = [s.f2; s.b2(:, :, 1)];
            xx(:, 1:s.LastSmooth-1) = NaN;
            xx(1:nf, s.LastSmooth) = NaN;
            ee = s.e2;
            preNaN = NaN;
            if s.IsOverrideMean
                % Add shock tunes to shocks
                ee = ee + s.OverrideMean;
                % If there are anticipated shocks, we need to create NaN+1i*NaN to
                % fill in the pre-sample values
                if ~isreal(s.OverrideMean)
                    preNaN = preNaN*(1+1i);
                end
            end
            ee(:, 1:s.LastSmooth) = preNaN;
            outputData.M2 = outputDataAssignFunc(outputData.M2, run, {yy, xx, ee, [], s.g});
        end

        % Return smooth std
        if s.retSmoothStd
            if nz>0
                s.Dy2 = s.Dy2([], :);
            end
            s.Dy2(:, 1:s.LastSmooth) = NaN;
            s.Df2(:, 1:s.LastSmooth) = NaN;
            s.Db2(:, 1:s.LastSmooth-1) = NaN;
            outputData.S2 = outputDataAssignFunc( ...
                outputData.S2, run, ...
                {s.Dy2*s.V, [s.Df2; s.Db2]*s.V, [], [], s.Dg2*s.V} ...
            );
        end

        % Return PE contributions to smooth step
        if s.retSmoothCont
            if nz>0
                s.yc2 = s.yc2([], :, :, :);
            end
            yy = s.yc2;
            yy = permute(yy, [1, 3, 2, 4]);
            xx = [s.fc2; s.bc2];
            xx = permute(xx, [1, 3, 2, 4]);
            ee = s.ec2;
            ee = permute(ee, [1, 3, 2, 4]);
            size3 = size(xx, 3);
            size4 = size(xx, 4);
            outputData.C2 = outputDataAssignFunc(outputData.C2, ':', {yy, xx, ee, [], []});
        end

        inxObjFunc = s.InxObjFunc & any(s.yindex, 1);
        s.SampleCov = ee(:, inxObjFunc)*ee(:, inxObjFunc).'/nnz(inxObjFunc);

        % Return smooth MSE for `xb`.
        if s.retSmoothMse
            s.Pb2(:, :, 1:s.LastSmooth-1) = NaN;
            outputData.Mse2.Data(:, :, :, run) = s.Pb2*s.V;
        end
    end%
end%




function s = here_ahead(s)
    % here_ahead  K-step ahead predictions and prediction errors for K>2 when
    % requested by caller. This function must be called after correction for
    % diffuse initial conditions and/or out-of-lik params has been made.

    % TODO: Make Ahead= work with time-varying state space matrices

    numExtendedPeriods = s.NumExtdPeriods;
    a0 = permute(s.a0, [1, 3, 4, 2]);
    pe = permute(s.pe, [1, 3, 4, 2]);
    y0 = permute(s.y0, [1, 3, 4, 2]);
    ydelta = permute(s.ydelta, [1, 3, 4, 2]);

    % Expand existing prediction vectors.
    a0 = cat(3, a0, nan([size(a0), s.Ahead-1]));
    pe = cat(3, pe, nan([size(pe), s.Ahead-1]));
    y0 = cat(3, y0, nan([size(y0), s.Ahead-1]));
    if s.retPred
        % `f0` exists and its k-step-ahead predictions need to be calculated only
        % if `pred` data are requested.
        f0 = permute(s.f0, [1, 3, 4, 2]);
        f0 = cat(3, f0, nan([size(f0), s.Ahead-1]));
    end

    bsxfunKa = size(s.ka, 2)==1;
    bsxfunD = size(s.d, 2)==1;
    for k = 2 : min(s.Ahead, numExtendedPeriods-1)
        t = 1+k : numExtendedPeriods;
        repeat = ones(1, numel(t));
        a0(:, t, k) = s.Ta*a0(:, t-1, k-1);
        if ~isempty(s.ka)
            if bsxfunKa
                a0(:, t, k) = bsxfun(@plus, a0(:, t, k), s.ka);
            else
                a0(:, t, k) = a0(:, t, k) + s.ka(:, t);
            end
        end
        y0(:, t, k) = s.Z*a0(:, t, k);
        if ~isempty(s.d)
            if bsxfunD
                y0(:, t, k) = bsxfun(@plus, y0(:, t, k), s.d);
            else
                y0(:, t, k) = y0(:, t, k) + s.d(:, t);
            end
        end
        if s.retPred
            f0(:, t, k) = s.Tf*a0(:, t-1, k-1);
            if ~isempty(s.kf)
                if ~s.IsOverrideMean
                    f0(:, t, k) = f0(:, t, k) + s.kf(:, repeat);
                else
                    f0(:, t, k) = f0(:, t, k) + s.kf(:, t);
                end
            end
        end
    end
    if s.NumOutlik>0
        y0(:, :, 2:end) = y0(:, :, 2:end) + ydelta(:, :, ones(1, s.Ahead-1));
    end
    pe(:, :, 2:end) = s.y1(:, :, ones(1, s.Ahead-1)) - y0(:, :, 2:end);

    s.a0 = ipermute(a0, [1, 3, 4, 2]);
    s.pe = ipermute(pe, [1, 3, 4, 2]);
    s.y0 = ipermute(y0, [1, 3, 4, 2]);
    s.ydelta = ipermute(ydelta, [1, 3, 4, 2]);
    if s.retPred
        s.f0 = ipermute(f0, [1, 3, 4, 2]);
    end
end%


function s = here_predictXibMean(s)
    %(
    s.b0 = s.a0;
    numPeriods = size(s.a0, 2);
    numPages = size(s.a0, 3);
    if ~isempty(s.U)
        for t = 1 : numPeriods
            U = s.U(:, :, min(t, end));
            for n = 1 : numPages
                s.b0(:, t, n) = U * s.a0(:, t, n);
            end
        end
    end
    %)
end%


function s = here_predictXifMse(s)
    nf = s.NumF;
    nb = s.NumB;
    numExtendedPeriods = s.NumExtdPeriods;

    s.Pf0 = nan(nf, nf, numExtendedPeriods);
    s.Pfa0 = nan(nf, nb, numExtendedPeriods);
    s.Df0 = nan(nf, numExtendedPeriods);
    for t = 2 : s.NumExtdPeriods
        Ta = s.Ta(:, :, min(t, end));
        Tf = s.Tf(:, :, min(t, end));
        Sf = s.Sf(:, :, min(t, end));
        Sfa = s.Sfa(:, :, min(t, end));

        TfPa1 = Tf*s.Pa1(:, :, t-1);
        Pf0 = TfPa1*Tf' + Sf;
        Pf0 = (Pf0 + Pf0')/2;
        s.Pf0(:, :, t) = Pf0;
        s.Pfa0(:, :, t) = TfPa1*Ta' + Sfa;
        s.Df0(:, t) = diag(Pf0);
    end
end%




function s = here_getPredXfMean(s)
% here_getPredXfMean  Point prediction step for fwl transition variables. The
% MSE matrices are computed in `xxSmoothMse` only when needed.
    if s.NumF==0
        return
    end
    for t = 2 : s.NumExtdPeriods
        % Prediction step
        Tf = s.Tf(:, :, min(t, end));
        jy1 = s.yindex(:, t-1);
        s.f0(:, 1, t) = Tf*(s.a0(:, 1, t-1) + s.K1(:, jy1, t-1)*s.pe(jy1, 1, t-1, 1));
        if ~isempty(s.kf)
            s.f0(:, 1, t) = s.f0(:, 1, t) + s.kf(:, min(t, end));
        end
    end
end%




function s = here_getUpdateMean(s)
    nf = s.NumF;
    nb = s.NumB;
    ne = s.NumE;
    nxp = s.NumExtdPeriods;
    yInx = s.yindex;
    lastObs = s.LastObs;

    s.b1 = nan(nb, nxp);
    s.f1 = nan(nf, nxp);
    s.e1 = nan(ne, nxp);
    % Note that `s.y1` already exists.

    s.e1(:, 2:end) = 0;
    if lastObs<nxp
        a0 = permute(s.a0(:, 1, :, 1), [1, 3, 4, 2]);
        if isempty(s.U)
            s.b1(:, lastObs+1:end) = a0(:, lastObs+1:end);
        elseif size(s.U, 3)==1
            s.b1(:, lastObs+1:end) = s.U*a0(:, lastObs+1:end);
        else
            for t = lastObs+1 : nxp
                U = s.U(:, :, min(t, end));
                s.b1(:, t) = U*a0(:, t);
            end
        end
        s.f1(:, lastObs+1:end) = s.f0(:, 1, lastObs+1:end, 1);
        s.y1(:, lastObs+1:end) = ipermute(s.y0(:, 1, lastObs+1:end, 1), [1, 3, 4, 2]);
    end

    for t = lastObs : -1 : 1
        j = yInx(:, t);
        d = [];
        if ~isempty(s.d)
            d = s.d(:, min(t, end));
        end
        [y1, f1, b1, e1] = iris.mixin.Kalman.oneStepBackMean( ...
            s, t, s.pe(:, 1, t, 1), s.a0(:, 1, t, 1), ...
            s.f0(:, 1, t, 1), s.ydelta(:, 1, t), d, 0 ...
        );
        s.y1(~j, t) = y1(~j, 1);
        if nf>0
            s.f1(:, t) = f1;
        end
        s.b1(:, t) = b1;
        s.e1(:, t) = e1;
    end
end%




function s = here_getUpdateMse(s)
    % here_getUpdateMse  MSE matrices for updating step.
    ny = s.NumY;
    nf = s.NumF;
    nb = s.NumB;
    ng = s.NumG;
    numExtendedPeriods = s.NumExtdPeriods;
    lastObs = s.LastObs;

    % Pre-allocation.
    if s.retFilterMse
        s.Pb1 = nan(nb, nb, numExtendedPeriods);
    end
    s.Db1 = nan(nb, numExtendedPeriods); % Diagonal of Pb2.
    s.Df1 = nan(nf, numExtendedPeriods); % Diagonal of Pf2.
    s.Dy1 = nan(ny, numExtendedPeriods); % Diagonal of Py2.
    s.Dg1 = [nan(ng, 1), zeros(ng, numExtendedPeriods-1)];

    if lastObs<numExtendedPeriods
        if s.retFilterMse
            s.Pb1(:, :, lastObs+1:numExtendedPeriods) = s.Pb0(:, :, lastObs+1:numExtendedPeriods);
        end
        s.Dy1(:, lastObs+1:numExtendedPeriods) = s.Dy0(:, lastObs+1:numExtendedPeriods);
        s.Df1(:, lastObs+1:numExtendedPeriods) = s.Df0(:, lastObs+1:numExtendedPeriods);
        s.Db1(:, lastObs+1:numExtendedPeriods) = s.Db0(:, lastObs+1:numExtendedPeriods);
    end

    for t = lastObs : -1 : 2
        [Pb1, Dy1, Df1, Db1] = here_oneStepBackMse(s, t, 0);
        if s.retFilterMse
            s.Pb1(:, :, t) = Pb1;
        end
        s.Dy1(:, t) = Dy1;
        if nf>0 && t>1
            s.Df1(:, t) = Df1;
        end
        s.Db1(:, t) = Db1;
    end
end%




function s = here_getSmoothMse(s)
    % here_getSmoothMse  Smoother for MSE matrices of all variables
    ny = s.NumY;
    nf = s.NumF;
    nb = s.NumB;
    ng = s.NumG;
    nxp = s.NumExtdPeriods;
    lastSmooth = s.LastSmooth;
    lastObs = s.LastObs;

    % Pre-allocation
    if s.retSmoothMse
        s.Pb2 = nan(nb, nb, nxp);
    end
    s.Db2 = nan(nb, nxp); % Diagonal of Pb2.
    s.Df2 = nan(nf, nxp); % Diagonal of Pf2.
    s.Dy2 = nan(ny, nxp); % Diagonal of Py2.
    s.Dg2 = [nan(ng, 1), zeros(ng, nxp-1)];

    if lastObs<nxp
        pos = lastObs+1:nxp;
        s.Pb2(:, :, pos) = s.Pb0(:, :, pos);
        s.Dy2(:, pos)    = s.Dy0(:, pos);
        s.Df2(:, pos)    = s.Df0(:, pos);
        s.Db2(:, pos)    = s.Db0(:, pos);
    end

    N = 0;
    for t = lastObs : -1 : lastSmooth
        [Pb2, Dy2, Df2, Db2, N] = here_oneStepBackMse(s, t, N);
        if s.retSmoothMse
            s.Pb2(:, :, t) = Pb2;
        end
        s.Dy2(:, t) = Dy2;
        if nf>0 && t>lastSmooth
            s.Df2(:, t) = Df2;
        end
        s.Db2(:, t) = Db2;
    end
end%




function s = here_getSmoothMean(s)
    % here_getSmoothMean  Kalman smoother for point estimates of all variables.
    nb = s.NumB;
    nf = s.NumF;
    ne = s.NumE;
    nxp = s.NumExtdPeriods;
    lastObs = s.LastObs;
    lastSmooth = s.LastSmooth;
    % Pre-allocation. Re-use first page of prediction data. Prediction data
    % can have multiple pages if ahead>1.
    a0 = permute(s.a0(:, 1, :, 1), [1, 3, 4, 2]);
    if isempty(s.U)
        s.b2 = a0;
    elseif size(s.U, 3)==1
        s.b2 = s.U*a0;
    else
        s.b2 = nan(nb, nxp);
        for t = 2 : nxp
            U = s.U(:, :, min(t, end));
            s.b2(:, t) = U*a0(:, t);
        end
    end
    s.f2 = permute(s.f0(:, 1, :, 1), [1, 3, 4, 2]);
    s.e2 = zeros(ne, nxp);
    s.y2 = s.y1(:, :, 1);
    % No need to run the smoother beyond last observation.
    s.y2(:, lastObs+1:end) = permute(s.y0(:, 1, lastObs+1:end, 1), [1, 3, 4, 2]);
    r = zeros(nb, 1);
    for t = lastObs : -1 : lastSmooth
        j = s.yindex(:, t);
        d = [];
        if ~isempty(s.d)
            d = s.d(:, min(t, end));
        end
        [y2, f2, b2, e2, r] = iris.mixin.Kalman.oneStepBackMean( ...
            s, t, s.pe(:, 1, t, 1), s.a0(:, 1, t, 1), ...
            s.f0(:, 1, t, 1), s.ydelta(:, 1, t), d, r ...
        );
        s.y2(~j, t) = y2(~j, 1);
        if nf>0
            s.f2(:, t) = f2;
        end
        s.b2(:, t) = b2;
        s.e2(:, t) = e2;
    end
end%




function [D, Ka, Kf] = here_overrideMean(s, R, opt)
    ne = s.NumE;
    ny = s.NumY;
    nf = s.NumF;
    nb = s.NumB;
    nxp = s.NumExtdPeriods;
    if opt.Deviation
        D = zeros(ny, nxp);
        Ka = zeros(nb, nxp);
        Kf = zeros(nf, nxp);
    else
        D = repmat(s.d, 1, nxp);
        Ka = repmat(s.ka, 1, nxp);
        Kf = repmat(s.kf, 1, nxp);
    end
    Rf = R(1:nf, :);
    Ra = R(nf+1:end, :);
    H = s.H;
    for t = 2 : max(s.LastVaryingU, s.LastVaryingE)
        e = [s.VaryingU(:, t) + s.VaryingE(:, t), s.VaryingE(:, t+1:s.LastVaryingE)];
        k = size(e, 2);
        D(:, t) = D(:, t) + H*e(:, 1);
        Kf(:, t) = Kf(:, t) + Rf(:, 1:ne*k)*e(:);
        Ka(:, t) = Ka(:, t) + Ra(:, 1:ne*k)*e(:);
    end
end%




function s = here_getReducedFormCovariance(this, v, s, opt)
    ny = s.NumY;
    nf = s.NumF;
    nb = s.NumB;
    inxV = s.InxV;
    inxW = s.InxW;

    %
    % Combine currently assigned StdCorr with user-supplied time-varying
    % Override and Multiply including one presample period used to
    % initialize the filter
    %
    s.Omg = getIthOmega(this, v, opt.OverrideStdcorr, opt.MultiplyStd, s.NumExtdPeriods);
    lastOmg = size(s.Omg, 3);

    %
    % Reduced-form cov matrices in transition equations
    %
    if any(inxV)
        lastR = size(s.Ra, 3);
        lastSa = max(lastOmg, lastR);
        s.Sa  = zeros(nb, nb, lastSa);
        s.Sf  = zeros(nf, nf, lastSa);
        s.Sfa = zeros(nf, nb, lastSa);
        for t = 1 : lastSa
            if t<=lastR
                Ra__ = s.Ra(:, inxV, t);
                Rf__ = s.Rf(:, inxV, t);
            end
            if t<=lastOmg
                OmgV__ = s.Omg(inxV, inxV, t);
            end
            s.Sa(:, :, t)  = Ra__ * OmgV__ * transpose(Ra__);
            s.Sf(:, :, t)  = Rf__ * OmgV__ * transpose(Rf__);
            s.Sfa(:, :, t) = Rf__ * OmgV__ * transpose(Ra__);
        end
    else
        s.Sa  = zeros(nb, nb);
        s.Sf  = zeros(nf, nf);
        s.Sfa = zeros(nf, nb);
    end

    %
    % Reduced-form cov matrices in measurement equations
    %
    if any(inxW)
        lastH = size(s.H, 3);
        lastSy  = max(lastOmg, lastH);
        s.Sy = zeros(ny, ny, lastSy);
        for t = 1 : lastSy
            if t<=lastH
                H_t = s.H(:, inxW, t);
            end
            if t<=lastOmg
                OmgW_t = s.Omg(inxW, inxW, t);
            end
            s.Sy(:, :, t) = H_t * OmgW_t * H_t';
        end
    else
        s.Sy = zeros(ny, ny);
    end

    if any(~isfinite(s.Sy(:)))
        thisError = { 'StateSpaceSystem:InfiniteCovariance'
                      'Measurement shock covariance matrices contaminated with Inf or NaN' };
        throw(exception.Base(thisError, 'error'));
    end
end%


%
% Local Functions
%


function [Pb, Dy, Df, Db, N] = here_oneStepBackMse(s, t, N)
% here_oneStepBackMse  One-step backward smoothing for MSE matrices
    ny = s.NumY;
    nf = s.NumF;
    lastSmooth = s.LastSmooth;
    inxObs = s.yindex(:, t);

    Z = s.Z(:, :, min(end, t));
    Zj = Z(inxObs, :);
    F = s.F(:, :, min(end, t));
    Fj = F(inxObs, inxObs);

    if isempty(s.U)
        U = [];
    else
        U = s.U(:, :, min(end, t));
    end

    if isempty(N) || all(N(:)==0)
        N = (Zj'/Fj)*Zj;
    else
        L = s.L(:, :, t);
        N = (Zj'/Fj)*Zj + L'*N*L;
    end

    Pa0 = s.Pa0(:, :, t);
    Pa0NPa0 = Pa0*N*Pa0;
    Pa = Pa0 - Pa0NPa0;
    Pa = (Pa + Pa')/2;
    Pb = iris.mixin.Kalman.PbFromPa(U, Pa);
    Db = diag(Pb);

    if nf>0 && t>lastSmooth
        % Fwl transition variables
        Pfa0 = s.Pfa0(:, :, t);
        Pf = s.Pf0(:, :, t) - Pfa0*N*Pfa0';
        % Pfa2 = s.Pfa0(:, :, t) - Pfa0N*s.Pa0(:, :, t);
        Pf = (Pf + Pf')/2;
        Df = diag(Pf);
    else
        Df = nan(nf, 1);
    end

    if ny>0
        % Measurement variables
        Py = F - Z*Pa0NPa0*Z';
        Py = (Py + Py')/2;
        Py(inxObs, :) = 0;
        Py(:, inxObs) = 0;
        Dy = diag(Py);
    end
end%

