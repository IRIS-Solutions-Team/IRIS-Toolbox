function [obj, regOutp, outputData] = kalmanFilter(this, inputData, outputData, outputDataAssignFunc, opt)
% kalmanFilter  Kalman filter
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

% This Kalman filter handles the following special cases:
% * non-stationary initial conditions (treated as fixed numbers);
% * measurement parameters concentrated out of likelihood;
% * time-varying std deviations;
% * conditioning of likelihood upon some measurement variables;
% * exclusion of some of the periods from likelihood;
% * k-step-ahead predictions;
% * tunes on the mean of shocks, combined anticipated and unanticipated;
% * missing observations entered as NaNs;
% * infinite std devs of measurement shocks equivalent to missing obs.
% * contributions of measurement variables to transition variables.

TYPE = @int8;

[ny, nxi, nb, nf, ne, ng, nz] = sizeOfSolution(this);
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

s = struct( );

s.MEASUREMENT_MATRIX_TOLERANCE = this.MEASUREMENT_MATRIX_TOLERANCE;
s.DIFFUSE_SCALE = this.DIFFUSE_SCALE;
s.OBJ_FUNC_PENALTY = this.OBJ_FUNC_PENALTY;

s.Ahead = opt.Ahead;
s.IsObjOnly = nargout<=1;
s.NumExtendedPeriods = numExtendedPeriods;
s.NumY  = ny;
s.NumXi = nxi;
s.NumB  = nb;
s.NumF  = nf;
s.NumE  = ne;
s.NumG  = ng;

s.IsSimulate = false;
if ~isequal(opt.Simulate, false)
    opt.Simulate = parseSimulateOptions(this, opt.Simulate{:});
    s.IsSimulate = strcmpi(opt.Simulate.Method, 'selective') ...
                   && ~isequal(opt.Simulate.NonlinWindow, 0) ...
                   && any(this.Equation.IxHash);
end

% Out-of-lik params cannot be used with ~opt.DTrends
numPouts = length(opt.OutOfLik);

% Struct with currently processed information. Initialise the invariant
% fields
s.ny = ny;
s.nb = nb;
s.nf = nf;
s.ne = ne;
s.NPOut = numPouts;

% Add pre-sample to objective function range and deterministic time trend
s.IxObjRange = [false, opt.ObjFuncRange];

% Do not adjust the option `'lastSmooth='` -- see comments in `loglikopt`
s.LastSmooth = opt.LastSmooth;

% Override shock means
tune = opt.tune;
maybeShockTunes = ~isempty(tune) && any(tune(:)~=0);
requiredForward = 0;
if maybeShockTunes
    tune(isnan(tune)) = 0;
    % Add pre-sample
    tune = [zeros(ne, 1, size(tune, 3)), tune];
    % Expected shocks and forward expansion
    inx = any(any(imag(tune)~=0, 3), 1);
    requiredForward = max([0, find(inx, 1, 'last')]) - 2;
end

% Total number of cycles.
nLoop = max(numPages, nv);
s.nPred = max(nLoop, s.Ahead);

% Pre-allocate output data.
if ~s.IsObjOnly
    requestOutp( );
end

% Pre-allocate the non-hdata output arguments.
nObj = 1;
if opt.ObjFuncContributions
    nObj = numExtendedPeriods;
end
obj = nan(nObj, nLoop);

if ~s.IsObjOnly
    % Regular (non-hdata) output arguments
    regOutp = struct( );
    regOutp.F = nan(ny, ny, numExtendedPeriods, nLoop);
    regOutp.Pe = nan(ny, numExtendedPeriods, s.nPred);
    regOutp.V = nan(1, nLoop);
    regOutp.Delta = nan(numPouts, nLoop);
    regOutp.PDelta = nan(numPouts, numPouts, nLoop);
    regOutp.SampleCov = nan(ne, ne, nLoop);
    regOutp.NLoop = nLoop;
    regOutp.Init = { nan(nb, 1, nLoop), nan(nb, nb, nLoop) };
end

% Prepare struct and options for non-linear simulations (prediction
% step).
sn = struct( );
if s.IsSimulate
    prepareSimulate( );
end

%
% Main loop
%

if ~s.IsObjOnly && opt.Progress
    progress = ProgressBar(sprintf('IRIS %s.kalmanFilter progress', class(this)));
end

inxSolutionAvailable = true(1, nv);
inxValidFactor = true(1, nLoop);

for iLoop = 1 : nLoop
    %
    % Next data
    % Measurement and exogenous variables, and initial observations of
    % measurement variables. Deterministic trends will be subtracted later on.
    %
    s.y1 = inputData(1:ny, :, min(iLoop, end));
    s.g  = inputData(ny+(1:ng), :, min(iLoop, end));
    
    s.IsShkTune = false;
    if maybeShockTunes
        s.tune = tune(:, :, min(iLoop, end));
        s.VaryingU = real(s.tune);
        s.VaryingE = imag(s.tune);
        s.VaryingU(isnan(s.VaryingU)) = 0;
        s.VaryingE(isnan(s.VaryingE)) = 0;
        s.LastVaryingU = max([0, find(any(s.VaryingU, 1), 1, 'last')]);
        s.LastVaryingE = max([0, find(any(s.VaryingE, 1), 1, 'last')]);
        s.IsShkTune = s.LastVaryingU>0 || s.LastVaryingE>0;
    end

    %
    % Next model solution
    %
    v = min(iLoop, nv);
    if iLoop<=nv
        [ T, R, k, s.Z, s.H, d, s.U, Zb, ...
          s.InxV, s.InxW, s.NUnit, s.InxInit ] = getIthKalmanSystem(this, v, requiredForward);
        if nz>0
            % Transition variables marked for measurement
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
            s.ka = [ ];
            s.kf = [ ];
            s.d  = [ ];
        else
            s.kf = k(1:nf, :);
            s.ka = k(nf+1:end, :);
            s.d  = d(:, :);
        end
        
        s = hereCalculateReducedFormCovariance(this, v, s, opt);
    end
    
    % Stop immediately if solution is not available; report NaN solutions
    % post mortem
    inxSolutionAvailable(iLoop) = all(isfinite(T(:)));
    if ~inxSolutionAvailable(iLoop)
        continue
    end

    
    % __Deterministic Trends__
    % y(t) - D(t) - X(t)*delta = Z*a(t) + H*e(t).
    if nz==0 && (numPouts>0 || opt.DTrends)
        [s.D, s.X] = evalTrendEquations(this, opt.OutOfLik, s.g, iLoop);
    else
        s.D = [ ];
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
    if s.IsShkTune 
        [s.d, s.ka, s.kf] = addShockTunes(s, R, opt);
    end

    % Index of available observations.
    s.yindex = ~isnan(s.y1);
    s.LastObs = max([ 0, find( any(s.yindex, 1), 1, 'last' ) ]);
    s.jyeq = [false, all(s.yindex(:, 2:end)==s.yindex(:, 1:end-1), 1) ];
    

    %
    % Initialize mean and MSE
    % Determine number of init cond estimated as fixed unknowns
    % 
    s = kalman.initialize(s, iLoop, opt);

    %
    % Prediction step
    %

    % Prepare the struct sn for nonlinear simulations in this round of
    % prediction steps.
    if s.IsSimulate
        sn.ILoop = iLoop;
        if iLoop<=nv
            sn = prepareSimulate2(this, sn, iLoop);
        end
    end
    
    % Run prediction error decomposition and evaluate user-requested
    % objective function.
    [obj(:, iLoop), s] = kalman.ped(s, sn, opt);
    inxValidFactor(iLoop) = abs(s.V)>this.VARIANCE_FACTOR_TOLERANCE;

    % Return immediately if only the value of the objective function is
    % requested.
    if s.IsObjOnly
        continue
    end
    
    % Prediction errors unadjusted (uncorrected) for estimated init cond
    % and DTrends; these are needed for contributions.
    if s.retCont
        s.peUnc = s.pe;
    end
    
    % Correct prediction errors for estimated initial conditions and DTrends
    % parameters.
    if s.NInit>0 || numPouts>0
        est = [s.delta; s.init];
        if s.storePredict
            [s.pe, s.a0, s.y0, s.ydelta] = ...
                kalman.correct(s, s.pe, s.a0, s.y0, est, s.d);
        else
            s.pe = kalman.correct(s, s.pe, [ ], [ ], est, [ ]);
        end
    end
    

    % Prediction step for fwl variables
    if s.retPredMse || s.retPredStd || s.retFilter || s.retSmooth
        s = hereGetPredXfMse(s);
    end
    if s.retPred || s.retSmooth
        % Predictions for forward-looking transtion variables have been already
        % filled in in non-linear predictions
        if ~s.IsSimulate
            s = hereGetPredXfMean(s);
        end
    end

    
    % Add k-step-ahead predictions
    if s.Ahead>1 && s.storePredict
        s = hereAhead(s);
    end


    % __Updating Step__
    if s.retFilter
        if s.retFilterStd || s.retFilterMse
            s = getFilterMse(s);
        end
        s = getFilterMean(s);
    end
    
    
    % __Smoother__
    % Run smoother for all variables.
    if s.retSmooth
        if s.retSmoothStd || s.retSmoothMse
            s = getSmoothMse(s);
        end
        s = getSmoothMean(s);
    end
    

    % __Contributions of Measurement Variables__
    if s.retCont
        s = kalman.cont(s);
    end
    
    % __Return Requested Data__
    % Columns in `pe` to be filled.
    if s.Ahead>1
        predCols = 1 : s.Ahead;
    else
        predCols = iLoop;
    end

    % Populate hdata output arguments.
    if s.retPred
        returnPred( );
    end
    if s.retFilter
        returnFilter( );
    end
    s.SampleCov = NaN;
    if s.retSmooth
        returnSmooth( );
    end
    
    % Populate regular (non-hdata) output arguments.
    regOutp.F(:, :, :, iLoop) = s.F*s.V;
    regOutp.Pe(:, :, predCols) = permute(s.pe, [1, 3, 4, 2]);
    regOutp.V(iLoop) = s.V;
    regOutp.Delta(:, iLoop) = s.delta;
    regOutp.PDelta(:, :, iLoop) = s.PDelta*s.V;
    regOutp.SampleCov(:, :, iLoop) = s.SampleCov;
    regOutp.Init{1}(:, :, iLoop) = s.InitMean;
    regOutp.Init{2}(:, :, iLoop) = s.InitMse;
    

    % __Update Progress Bar__
    if opt.Progress
        update(progress, iLoop/nLoop);
    end
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




    function requestOutp( )
        s.retPredMean   = isfield(outputData, 'M0');
        s.retPredMse    = isfield(outputData, 'Mse0');
        s.retPredStd    = isfield(outputData, 'S0');
        s.retPredCont   = isfield(outputData, 'C0');
        s.retFilterMean = isfield(outputData, 'M1');
        s.retFilterMse  = isfield(outputData, 'Mse1');
        s.retFilterStd  = isfield(outputData, 'S1');
        s.retFilterCont = isfield(outputData, 'C1');
        s.retSmoothMean = isfield(outputData, 'M2');
        s.retSmoothMse  = isfield(outputData, 'Mse2');
        s.retSmoothStd  = isfield(outputData, 'S2');
        s.retSmoothCont = isfield(outputData, 'C2');
        s.retPred       = s.retPredMean || s.retPredStd || s.retPredMse;
        s.retFilter     = s.retFilterMean || s.retFilterStd || s.retFilterMse;
        s.retSmooth     = s.retSmoothMean || s.retSmoothStd || s.retSmoothMse;
        s.retCont       = s.retPredCont || s.retFilterCont || s.retSmoothCont;
        s.storePredict  = s.Ahead>1 || s.retPred || s.retFilter || s.retSmooth;
    end%



    
    function returnPred( )
        % Return pred mean.
        % Note that s.y0, s.f0 and s.a0 include k-sted-ahead predictions if
        % ahead>1.
        if s.retPredMean
            if nz>0
                s.y0 = s.y0([ ], :, :, :);
            end
            yy = permute(s.y0, [1, 3, 4, 2]);
            yy(:, 1, :) = NaN;
            if ~isempty(s.D)
                yy = yy + repmat(s.D, 1, 1, s.Ahead);
            end
            % Convert `alpha` predictions to `xb` predictions. The
            % `a0` may contain k-step-ahead predictions in 3rd dimension.
            bb = permute(s.a0, [1, 3, 4, 2]);
            if ~isempty(s.U)
                if size(s.U, 3)==1
                    for ii = 1 : size(bb, 3)
                        bb(:, :, ii) = s.U*bb(:, :, ii);
                    end
                else
                    for tt = 2 : s.NumExtendedPeriods
                        U = s.U(:, :, min(tt, end));
                        for ii = 1 : size(bb, 3)
                            bb(:, tt, ii) = U*bb(:, tt, ii);
                        end
                    end
                end
            end
            ff = permute(s.f0, [1, 3, 4, 2]);
            xx = [ff; bb];
            % Shock predictions are always zeros.
            ee = zeros(ne, numExtendedPeriods, s.Ahead);
            % Set predictions for the pre-sample period to `NaN`.
            xx(:, 1, :) = NaN;
            ee(:, 1, :) = NaN;
            % Add fixed deterministic trends back to measurement vars.
            % Add shock tunes to shocks.
            if s.IsShkTune
                ee = ee + repmat(s.tune, 1, 1, s.Ahead);
            end
            % Do not use lags in the prediction output data.
            outputData.M0 = outputDataAssignFunc(outputData.M0, predCols, {yy, xx, ee, [ ], [ ]});
        end
        
        % Return pred std
        if s.retPredStd
            if nz>0
                s.Dy0 = s.Dy0([ ], :);
            end
            % Do not use lags in the prediction output data
            outputData.S0 = outputDataAssignFunc( outputData.S0, iLoop, ...
                                                  {s.Dy0*s.V, [s.Df0; s.Db0]*s.V, s.De0*s.V, [ ], [ ]} );
        end
        
        % Return prediction MSE for xb.
        if s.retPredMse
            outputData.Mse0.Data(:, :, :, iLoop) = s.Pb0*s.V;
        end

        % Return PE contributions to prediction step.
        if s.retPredCont
            if nz>0
                s.yc0 = s.yc0([ ], :, :, :);
            end
            yy = s.yc0;
            yy = permute(yy, [1, 3, 2, 4]);
            xx = [s.fc0;s.bc0];
            xx = permute(xx, [1, 3, 2, 4]);
            xx(:, 1, :) = NaN;
            ee = s.ec0;
            ee = permute(ee, [1, 3, 2, 4]);
            gg = [nan(ng, 1), zeros(ng, numExtendedPeriods-1)];
            outputData.predcont = outputDataAssignFunc(outputData.predcont, ':', {yy, xx, ee, [ ], gg});
        end
    end%




    function returnFilter( )        
        if s.retFilterMean
            if nz>0
                s.y1 = s.y1([ ], :);
            end
            yy = s.y1;
            % Add fixed deterministic trends back to measurement vars.
            if ~isempty(s.D)
                yy = yy + s.D;
            end
            xx = [s.f1; s.b1];
            ee = s.e1;
            % Add shock tunes to shocks.
            if s.IsShkTune
                ee = ee + s.tune;
            end
            % Do not use lags in the filter output data.
            outputData.M1 = outputDataAssignFunc(outputData.M1, iLoop, {yy, xx, ee, [ ], s.g});
        end
        
        % Return PE contributions to filter step.
        if s.retFilterCont
            if nz>0
                s.yc1 = s.yc1([ ], :, :, :);
            end
            yy = s.yc1;
            yy = permute(yy, [1, 3, 2, 4]);
            xx = [s.fc1; s.bc1];
            xx = permute(xx, [1, 3, 2, 4]);
            ee = s.ec1;
            ee = permute(ee, [1, 3, 2, 4]);
            gg = [nan(ng, 1), zeros(ng, numExtendedPeriods-1)];
            outputData.filtercont = outputDataAssignFunc(outputData.filtercont, ':', {yy, xx, ee, [ ], gg});
        end
        
        % Return filter std.
        if s.retFilterStd
            if nz>0
                s.Dy1 = s.Dy1([ ], :);
            end
            outputData.S1 = outputDataAssignFunc( outputData.S1, iLoop, ...
                                                  {s.Dy1*s.V, [s.Df1;s.Db1]*s.V, [ ], [ ], s.Dg1*s.V} );
        end
        
        % Return filtered MSE for `xb`.
        if s.retFilterMse
            %s.Pb1(:, :, 1) = NaN;
            outputData.Mse1.Data(:, :, :, iLoop) = s.Pb1*s.V;
        end
    end%




    function returnSmooth( )
        if s.retSmoothMean
            if nz>0
                s.y2 = s.y2([ ], :);
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
            if s.IsShkTune
                % Add shock tunes to shocks
                ee = ee + s.tune;
                % If there were anticipated shocks (imag), we need to create NaN+1i*NaN to
                % fill in the pre-sample values
                if ~isreal(s.tune);
                    preNaN = preNaN*(1+1i);
                end
            end
            ee(:, 1:s.LastSmooth) = preNaN;
            outputData.M2 = outputDataAssignFunc(outputData.M2, iLoop, {yy, xx, ee, [ ], s.g});
        end
        
        % Return smooth std
        if s.retSmoothStd
            if nz>0
                s.Dy2 = s.Dy2([ ], :);
            end
            s.Dy2(:, 1:s.LastSmooth) = NaN;
            s.Df2(:, 1:s.LastSmooth) = NaN;
            s.Db2(:, 1:s.LastSmooth-1) = NaN;
            outputData.S2 = outputDataAssignFunc( outputData.S2, iLoop, ...
                                                  {s.Dy2*s.V, [s.Df2; s.Db2]*s.V, [ ], [ ], s.Dg2*s.V} );
        end
        
        % Return PE contributions to smooth step
        if s.retSmoothCont
            if nz>0
                s.yc2 = s.yc2([ ], :, :, :);
            end
            yy = s.yc2;
            yy = permute(yy, [1, 3, 2, 4]);
            xx = [s.fc2; s.bc2];
            xx = permute(xx, [1, 3, 2, 4]);
            ee = s.ec2;
            ee = permute(ee, [1, 3, 2, 4]);
            size3 = size(xx, 3);
            size4 = size(xx, 4);
            gg = [nan(ng, 1, size3, size4), zeros(ng, numExtendedPeriods-1, size3, size4)];
            outputData.C2 = outputDataAssignFunc(outputData.C2, ':', {yy, xx, ee, [ ], gg});
        end
        
        ixObjRange = s.IxObjRange & any(s.yindex, 1);
        s.SampleCov = ee(:, ixObjRange)*ee(:, ixObjRange).'/sum(ixObjRange);
        
        % Return smooth MSE for `xb`.
        if s.retSmoothMse
            s.Pb2(:, :, 1:s.LastSmooth-1) = NaN;
            outputData.Mse2.Data(:, :, :, iLoop) = s.Pb2*s.V;
        end
    end%




    function prepareSimulate( )
        sn.Anch = false(ny+nxi+ne+ne, 1);
        sn.Wght = sparse(ne+ne, 1);
        sn.NPer = 1;
        sn.progress = [ ];
        sn.Alp0 = [ ];
        sn.Ea = zeros(ne, 1);
        sn.Eu = zeros(ne, 1);
        sn.Tune = sparse(ny+nxi, 1);
        sn.ZerothSegment = 0;
        sn.NLoop = nLoop;
        sn.LastEndgA = 0;
        sn.LastEndgU = 0;
        sn.LastEa = 0;
        displayMode = 'Silent';
        sn = prepareSimulate1(this, sn, opt.Simulate, displayMode);
    end%
end%




function s = hereAhead(s)
    % hereAhead  K-step ahead predictions and prediction errors for K>2 when
    % requested by caller. This function must be called after correction for
    % diffuse initial conditions and/or out-of-lik params has been made.

    % TODO: Make Ahead= work with time-varying state space matrices
    
    numExtendedPeriods = s.NumExtendedPeriods;
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
                if ~s.IsShkTune
                    f0(:, t, k) = f0(:, t, k) + s.kf(:, repeat);
                else
                    f0(:, t, k) = f0(:, t, k) + s.kf(:, t);
                end
            end
        end
    end
    if s.NPOut>0
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




function s= hereGetPredXfMse(s)
    nf = s.NumF;
    nb = s.NumB;
    numExtendedPeriods = s.NumExtendedPeriods;

    s.Pf0 = nan(nf, nf, numExtendedPeriods);
    s.Pfa0 = nan(nf, nb, numExtendedPeriods);
    s.Df0 = nan(nf, numExtendedPeriods);
    for t = 2 : s.NumExtendedPeriods
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




function s = hereGetPredXfMean(s)
% hereGetPredXfMean  Point prediction step for fwl transition variables. The
% MSE matrices are computed in `xxSmoothMse` only when needed.
    if s.NumF==0
        return
    end
    for t = 2 : s.NumExtendedPeriods
        % Prediction step
        Tf = s.Tf(:, :, min(t, end));
        jy1 = s.yindex(:, t-1);
        s.f0(:, 1, t) = Tf*(s.a0(:, 1, t-1) + s.K1(:, jy1, t-1)*s.pe(jy1, 1, t-1, 1));
        if ~isempty(s.kf)
            s.f0(:, 1, t) = s.f0(:, 1, t) + s.kf(:, min(t, end));
        end
    end
end%




function s = getFilterMean(s)
    nf = s.NumF;
    nb = s.NumB;
    ne = s.NumE;
    nxp = s.NumExtendedPeriods;
    yInx = s.yindex;
    lastObs = s.LastObs;

    % Pre-allocation. Re-use first page of prediction data. Prediction data
    % can have multiple pages if `ahead`>1.
    s.b1 = nan(nb, nxp);
    s.f1 = nan(nf, nxp);
    s.e1 = nan(ne, nxp);
    % Note that `s.y1` already exists.

    s.e1(:, 2:end) = 0;
    if lastObs<nxp
        a0 = permute(s.a0(:, 1, :, 1), [1, 3, 4, 2]);
        if ~isempty(s.U)
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

    for t = lastObs : -1 : 2
        j = yInx(:, t);
        d = [ ];
        if ~isempty(s.d)
            d = s.d(:, min(t, end));
        end
        [y1, f1, b1, e1] = kalman.oneStepBackMean( s, t, s.pe(:, 1, t, 1), s.a0(:, 1, t, 1), ...
                                                   s.f0(:, 1, t, 1), s.ydelta(:, 1, t), d, 0 );
        s.y1(~j, t) = y1(~j, 1);
        if nf>0
            s.f1(:, t) = f1;
        end
        s.b1(:, t) = b1;
        s.e1(:, t) = e1;
    end
end%




function s = getFilterMse(s)
    % getFilterMse  MSE matrices for updating step.
    ny = s.NumY;
    nf = s.NumF;
    nb = s.NumB;
    ng = s.NumG;
    numExtendedPeriods = s.NumExtendedPeriods;
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
        [Pb1, Dy1, Df1, Db1] = hereOneStepBackMse(s, t, 0);
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




function s = getSmoothMse(s)
    % getSmoothMse  Smoother for MSE matrices of all variables
    ny = s.NumY;
    nf = s.NumF;
    nb = s.NumB;
    ng = s.NumG;
    nxp = s.NumExtendedPeriods;
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
        [Pb2, Dy2, Df2, Db2, N] = hereOneStepBackMse(s, t, N);
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




function s = getSmoothMean(s)
    % getSmoothMean  Kalman smoother for point estimates of all variables.
    nb = s.NumB;
    nf = s.NumF;
    ne = s.NumE;
    nxp = s.NumExtendedPeriods;
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
        d = [ ];
        if ~isempty(s.d)
            d = s.d(:, min(t, end));
        end
        [y2, f2, b2, e2, r] = kalman.oneStepBackMean( s, t, s.pe(:, 1, t, 1), s.a0(:, 1, t, 1), ...
                                                      s.f0(:, 1, t, 1), s.ydelta(:, 1, t), d, r );
        s.y2(~j, t) = y2(~j, 1);
        if nf>0
            s.f2(:, t) = f2;
        end
        s.b2(:, t) = b2;
        s.e2(:, t) = e2;
    end
end%




function [D, Ka, Kf] = addShockTunes(s, R, opt)
    % addShockTunes  Add tunes on shock means to constant terms
    ne = s.NumE;
    ny = s.NumY;
    nf = s.NumF;
    nb = s.NumB;
    nxp = s.NumExtendedPeriods;
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




function s = hereCalculateReducedFormCovariance(this, v, s, opt)
    ny = s.NumY;
    nf = s.NumF;
    nb = s.NumB;
    ne = s.NumE;
    nxp = s.NumExtendedPeriods;
    inxV = s.InxV;
    inxW = s.InxW;

    %
    % Combine currently assigned StdCorr with user-supplied time-varying
    % Override and Multiply including one presample period used to
    % initialize the filter
    %
    s.Omg = getIthOmega(this, v, opt.OverrideStdcorr, opt.MultiplyStd, nxp);
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
                Ra_t = s.Ra(:, inxV, t);
                Rf_t = s.Rf(:, inxV, t);
            end
            if t<=lastOmg
                OmgV_t = s.Omg(inxV, inxV, t);
            end
            s.Sa(:, :, t)  = Ra_t * OmgV_t * Ra_t';
            s.Sf(:, :, t)  = Rf_t * OmgV_t * Rf_t';
            s.Sfa(:, :, t) = Rf_t * OmgV_t * Ra_t';
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


function [Pb, Dy, Df, Db, N] = hereOneStepBackMse(s, t, N)
% hereOneStepBackMse  One-step backward smoothing for MSE matrices
    ny = s.NumY;
    nf = s.NumF;
    lastSmooth = s.LastSmooth;
    inxObs = s.yindex(:, t);

    Z = s.Z(:, :, min(end, t));
    Zj = Z(inxObs, :);
    F = s.F(:, :, min(end, t));
    Fj = F(inxObs, inxObs);

    if isempty(s.U)
        U = [ ];
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
    if isempty(U)
        Pb = Pa;
    else
        Pb = kalman.pa2pb(U, Pa);
    end
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

