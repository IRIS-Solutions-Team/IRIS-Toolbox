function [obj, regOutp, hData] = kalmanFilter(this, inp, hData, opt, varargin)
% kalmanFilter  Run Kalman filter
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
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
MSE_TOLERANCE = this.Tolerance.Mse;
EIGEN_TOLERANCE = this.Tolerance.Eigen;
DIFFUSE_SCALE = 1e8;

[ny, nxx, nb, nf, ne, ng, nz] = sizeOfSolution(this);
if nz>0
    ny = nz;
end

nv = length(this);
numOfDataSets = size(inp, 3);

if ~isequal(opt.simulate, false)
    opt.simulate = parseSimulateOptions(this, opt.simulate{:});
end

%--------------------------------------------------------------------------

s = struct( );
s.EIGEN_TOLERANCE = EIGEN_TOLERANCE;
s.DIFFUSE_SCALE = DIFFUSE_SCALE;
s.Ahead = opt.Ahead;
s.IsObjOnly = nargout<=1;
s.ObjFunPenalty = this.OBJ_FUNC_PENALTY;

s.IsSimulate = false;
if ~isequal(opt.simulate, false)
    s.IsSimulate = strcmpi(opt.simulate.Method, 'selective') ...
                   && ~isequal(opt.simulate.NonlinWindow, 0) ...
                   && any(this.Equation.IxHash);
end

% Out-of-lik params cannot be used with ~opt.DTrends.
numOfPouts = length(opt.outoflik);

% Extended number of periods including pre-sample.
numOfPeriods = size(inp, 2) + 1;

% Struct with currently processed information. Initialise the invariant
% fields.
s.ny = ny;
s.nx = nxx;
s.nb = nb;
s.nf = nf;
s.ne = ne;
s.NPOut = numOfPouts;

% Add pre-sample to objective function range and deterministic time trend.
s.IxObjRange = [false, opt.objrange];

% Do not adjust the option `'lastSmooth='` -- see comments in `loglikopt`.
s.lastSmooth = opt.lastsmooth;

% Tunes on shock means; model solution is expanded within `prepareLoglik`.
tune = opt.tune;
maybeShockTunes = ~isempty(tune) && any( tune(:)~=0 );
if maybeShockTunes
    % Add pre-sample
    tune = [zeros(ne, 1, size(tune, 3)), tune];
end

% Total number of cycles.
nLoop = max(numOfDataSets, nv);
s.nPred = max(nLoop, s.Ahead);

% Pre-allocate output data.
if ~s.IsObjOnly
    requestOutp( );
end

% Pre-allocate the non-hdata output arguments.
nObj = 1;
if opt.objdecomp
    nObj = numOfPeriods;
end
obj = nan(nObj, nLoop);

if ~s.IsObjOnly
    % Regular (non-hdata) output arguments.
    regOutp = struct( );
    regOutp.F = nan(ny, ny, numOfPeriods, nLoop);
    regOutp.Pe = nan(ny, numOfPeriods, s.nPred);
    regOutp.V = nan(1, nLoop);
    regOutp.Delta = nan(numOfPouts, nLoop);
    regOutp.PDelta = nan(numOfPouts, numOfPouts, nLoop);
    regOutp.SampleCov = nan(ne, ne, nLoop);
    regOutp.NLoop = nLoop;
end

% Prepare struct and options for non-linear simulations (prediction
% step).
sn = struct( );
if s.IsSimulate
    prepareSimulate( );
end

% __Main Loop__

if ~s.IsObjOnly && opt.progress
    progress = ProgressBar('IRIS Model.kalmanFilter progress');
end

inxOfSolved = true(1, nv);
ixValidFactor = true(1, nLoop);

for iLoop = 1 : nLoop
    % __Next Data__
    % Measurement and exogenous variables, and initial observations of
    % measurement variables. Deterministic trends will be subtracted later on.
    s.y1 = inp(1:ny, :, min(iLoop, end));
    s.g = inp(ny+1:end, :, min(iLoop, end));
    
    % Add pre-sample initial condition.
    s.y1 = [nan(ny, 1), s.y1];
    s.g = [nan(ng, 1), s.g];
    
    if maybeShockTunes
        s.tune = tune(:, :, min(iLoop, end));
        s.VaryingU = real(s.tune);
        s.VaryingE = imag(s.tune);
        s.VaryingU(isnan(s.VaryingU)) = 0;
        s.VaryingE(isnan(s.VaryingE)) = 0;
        s.LastVaryingU = max([0, find(any(s.VaryingU, 1), 1, 'last')]);
        s.LastVaryingE = max([0, find(any(s.VaryingE, 1), 1, 'last')]);
        s.IsShkTune = s.LastVaryingU>0 || s.LastVaryingE>0;
    else
        s.IsShkTune = false;
    end


    % __Next Model Solution__
    v = min(iLoop, nv);
    if iLoop<=nv
        [T, R, k, s.Z, s.H, s.d, s.U, ~, Zb, ~, s.InxOfEM, s.InxOfET] = sspaceMatrices(this, v);
        if nz>0
            % Transition variables marked for measurement
            s.Z = Zb*s.U;
            s.H = zeros(nz, ne);
            s.d = zeros(nz, 1);
        end

        s.IxRequired = this.Variant.IxInit(:, :, v);
        s.NUnit = getNumOfUnitRoots(this.Variant, v);
        s.Tf = T(1:nf, :);
        s.Ta = T(nf+1:end, :);
        % Keep forward expansion for computing the effect of tunes on shock
        % means. Cut off the expansion within subfunctions.
        s.Rf = R(1:nf, :);
        s.Ra = R(nf+1:end, :);
        s.Zt = s.Z.';
        if opt.Deviation
            s.ka = [ ];
            s.kf = [ ];
            s.d = [ ];
        else
            s.kf = k(1:nf, :);
            s.ka = k(nf+1:end, :);
        end
        
        % _Time-Varying StdCorr and StdScale_
        % Combine currently assigned StdCorr with user-supplied
        % time-varying StdCorr and StdScale including one presample period
        % used to initialize the filter
        sx = combineStdCorr(this.Variant, v, opt.StdCorr, opt.StdScale, numOfPeriods);
        
        % Create covariance matrix from stdcorr vector
        s.Omg = covfun.stdcorr2cov(sx, ne);
        
        % Create reduced form covariance matrices `Sa` and `Sy`, and find
        % measurement variables with infinite measurement shocks, `syinf`.
        s = convertOmg2SaSy(s, sx);
        
        % Free memory.
        clear sx;
    end
    
    % Continue immediately if solution is not available; report NaN solutions
    % post mortem.
    inxOfSolved(iLoop) = all(~isnan(T(:)));
    if ~inxOfSolved(iLoop)
        continue
    end

    
    % __Deterministic Trends__
    % y(t) - D(t) - X(t)*delta = Z*a(t) + H*e(t).
    if nz==0 && (numOfPouts>0 || opt.DTrends)
        [s.D, s.X] = evalTrendEquations(this, opt.outoflik, s.g, iLoop);
    else
        s.D = [ ];
        s.X = zeros(ny, 0, numOfPeriods);
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
        currentForward = size(R, 2)/ne - 1;
        requiredForward = s.LastVaryingE - 2;
        if requiredForward>currentForward
            vthExpansion = getIthFirstOrderExpansion(this.Variant, v);
            R = model.expandFirstOrder(R, [ ], vthExpansion, requiredForward);
        end
        [s.d, s.ka, s.kf] = addShockTunes(s, R, opt);
    end

    % Make measurement variables with `Inf` measurement shocks look like
    % missing. The `Inf` measurement shocks are detected in `xxomg2sasy`.
    s.y1(s.syinf) = NaN;
    
    % Index of available observations.
    s.yindex = ~isnan(s.y1);
    s.LastObs = max([ 0, find( any(s.yindex, 1), 1, 'last' ) ]);
    s.jyeq = [false, all(s.yindex(:, 2:end)==s.yindex(:, 1:end-1), 1) ];
    

    % __Initialize__
    % * Initial mean and MSE
    % * Number of init cond estimated as fixed unknowns
    s = kalman.initialize(s, iLoop, opt);

    % __Prediction Step__
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
    ixValidFactor(iLoop) = abs(s.V)>MSE_TOLERANCE;

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
    if s.NInit>0 || numOfPouts>0
        est = [s.delta; s.init];
        if s.storePredict
            [s.pe, s.a0, s.y0, s.ydelta] = ...
                kalman.correct(s, s.pe, s.a0, s.y0, est, s.d);
        else
            s.pe = kalman.correct(s, s.pe, [ ], [ ], est, [ ]);
        end
    end
    
    % Calculate prediction steps for fwl variables.
    if s.retPred || s.retSmooth
        s.isxfmse = s.retPredStd || s.retPredMse ...
            || s.retSmoothStd || s.retSmoothMse;
        % Predictions for forward-looking transtion variables have been already
        % filled in in non-linear predictions.
        if ~s.IsSimulate
            s = getPredXfMean(s);
        end
    end
    
    % Add k-step-ahead predictions.
    if s.Ahead>1 && s.storePredict
        s = goAhead(s);
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
    

    % __Update Progress Bar__
    if opt.progress
        update(progress, iLoop/nLoop);
    end
end 

if ~all(inxOfSolved)
    throw( exception.Base('Model:SolutionNotAvailable', 'warning'), ...
           exception.Base.alt2str(~inxOfSolved) ); %#ok<GTARG>
end

if any(~ixValidFactor)
    throw( exception.Base('Model:ZeroVarianceFactor', 'warning'), ...
           exception.Base.alt2str(~ixValidFactor) ); %#ok<GTARG>        
end

return




    function requestOutp( )
        s.retPredMean = isfield(hData, 'M0');
        s.retPredMse = isfield(hData, 'Mse0');
        s.retPredStd = isfield(hData, 'S0');
        s.retPredCont = isfield(hData, 'C0');
        s.retFilterMean = isfield(hData, 'M1');
        s.retFilterMse = isfield(hData, 'Mse1');
        s.retFilterStd = isfield(hData, 'S1');
        s.retFilterCont = isfield(hData, 'C1');
        s.retSmoothMean = isfield(hData, 'M2');
        s.retSmoothMse = isfield(hData, 'Mse2');
        s.retSmoothStd = isfield(hData, 'S2');
        s.retSmoothCont = isfield(hData, 'C2');
        s.retPred = s.retPredMean || s.retPredStd || s.retPredMse;
        s.retFilter = s.retFilterMean || s.retFilterStd || s.retFilterMse;
        s.retSmooth = s.retSmoothMean || s.retSmoothStd || s.retSmoothMse;
        s.retCont = s.retPredCont || s.retFilterCont || s.retSmoothCont;
        s.storePredict = s.Ahead>1 || s.retPred || s.retFilter || s.retSmooth;
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
            for ii = 1 : size(bb, 3)
                bb(:, :, ii) = s.U*bb(:, :, ii);
            end
            ff = permute(s.f0, [1, 3, 4, 2]);
            xx = [ff;bb];
            % Shock predictions are always zeros.
            ee = zeros(ne, numOfPeriods, s.Ahead);
            % Set predictions for the pre-sample period to `NaN`.
            xx(:, 1, :) = NaN;
            ee(:, 1, :) = NaN;
            % Add fixed deterministic trends back to measurement vars.
            % Add shock tunes to shocks.
            if s.IsShkTune
                ee = ee + repmat(s.tune, 1, 1, s.Ahead);
            end
            % Do not use lags in the prediction output data.
            hdataassign(hData.M0, predCols, { yy, xx, ee, [ ], [ ] } );
        end
        
        % Return pred std.
        if s.retPredStd
            if nz>0
                s.Dy0 = s.Dy0([ ], :);
            end
            % Do not use lags in the prediction output data.
            hdataassign(hData.S0, iLoop, ...
                {s.Dy0*s.V, ...
                [s.Df0; s.Db0]*s.V, ...
                s.De0*s.V, ...
                [ ], ...
                [ ], ...
                });
        end
        
        % Return prediction MSE for xb.
        if s.retPredMse
            hData.Mse0.Data(:, :, :, iLoop) = s.Pb0*s.V;
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
            gg = [nan(ng, 1), zeros(ng, numOfPeriods-1)];
            hdataassign(hData.predcont, ':', { yy, xx, ee, [ ], gg } );
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
            hdataassign(hData.M1, iLoop, { yy, xx, ee, [ ], s.g } );
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
            gg = [nan(ng, 1), zeros(ng, numOfPeriods-1)];
            hdataassign(hData.filtercont, ':', { yy, xx, ee, [ ], gg } );
        end
        
        % Return filter std.
        if s.retFilterStd
            if nz>0
                s.Dy1 = s.Dy1([ ], :);
            end
            hdataassign(hData.S1, iLoop, ...
                { ...
                s.Dy1*s.V, ...
                [s.Df1;s.Db1]*s.V, ...
                [ ], ...
                [ ], ...
                s.Dg1*s.V, ...
                });
        end
        
        % Return filtered MSE for `xb`.
        if s.retFilterMse
            %s.Pb1(:, :, 1) = NaN;
            hData.Mse1.Data(:, :, :, iLoop) = s.Pb1*s.V;
        end
    end%




    function returnSmooth( )
        if s.retSmoothMean
            if nz>0
                s.y2 = s.y2([ ], :);
            end
            yy = s.y2;
            yy(:, 1:s.lastSmooth) = NaN;
            % Add deterministic trends to measurement vars.
            if ~isempty(s.D)
                yy = yy + s.D;
            end
            xx = [s.f2; s.b2(:, :, 1)];
            xx(:, 1:s.lastSmooth-1) = NaN;
            xx(1:nf, s.lastSmooth) = NaN;
            ee = s.e2;
            preNaN = NaN;
            if s.IsShkTune
                % Add shock tunes to shocks.
                ee = ee + s.tune;
                % If there were anticipated shocks (imag), we need to create NaN+1i*NaN to
                % fill in the pre-sample values.
                if ~isreal(s.tune);
                    preNaN = preNaN*(1+1i);
                end
            end
            ee(:, 1:s.lastSmooth) = preNaN;
            hdataassign(hData.M2, iLoop, { yy, xx, ee, [ ], s.g } );
        end
        
        % Return smooth std.
        if s.retSmoothStd
            if nz>0
                s.Dy2 = s.Dy2([ ], :);
            end
            s.Dy2(:, 1:s.lastSmooth) = NaN;
            s.Df2(:, 1:s.lastSmooth) = NaN;
            s.Db2(:, 1:s.lastSmooth-1) = NaN;
            hdataassign(hData.S2, iLoop, ...
                { ...
                s.Dy2*s.V, ...
                [s.Df2; s.Db2]*s.V, ...
                [ ], ...
                [ ], ...
                s.Dg2*s.V, ...
                });
        end
        
        % Return PE contributions to smooth step.
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
            gg = [nan(ng, 1, size3, size4), zeros(ng, numOfPeriods-1, size3, size4)];
            hdataassign(hData.C2, ':', { yy, xx, ee, [ ], gg } );
        end
        
        ixObjRange = s.IxObjRange & any(s.yindex, 1);
        s.SampleCov = ee(:, ixObjRange)*ee(:, ixObjRange).'/sum(ixObjRange);
        
        % Return smooth MSE for `xb`.
        if s.retSmoothMse
            s.Pb2(:, :, 1:s.lastSmooth-1) = NaN;
            hData.Mse2.Data(:, :, :, iLoop) = s.Pb2*s.V;
        end
    end%




    function prepareSimulate( )
        sn.Anch = false(ny+nxx+ne+ne, 1);
        sn.Wght = sparse(ne+ne, 1);
        sn.NPer = 1;
        sn.progress = [ ];
        sn.Alp0 = [ ];
        sn.Ea = zeros(ne, 1);
        sn.Eu = zeros(ne, 1);
        sn.Tune = sparse(ny+nxx, 1);
        sn.ZerothSegment = 0;
        sn.NLoop = nLoop;
        sn.LastEndgA = 0;
        sn.LastEndgU = 0;
        sn.LastEa = 0;
        displayMode = 'Silent';
        sn = prepareSimulate1(this, sn, opt.simulate, displayMode);
    end%
end%




function S = goAhead(S)
    % goAhead  K-step ahead predictions and prediction errors for K>2 when
    % requested by caller. This function must be called after correction for
    % diffuse initial conditions and/or out-of-lik params has been made.

    a0 = permute(S.a0, [1, 3, 4, 2]);
    pe = permute(S.pe, [1, 3, 4, 2]);
    y0 = permute(S.y0, [1, 3, 4, 2]);
    ydelta = permute(S.ydelta, [1, 3, 4, 2]);

    % Expand existing prediction vectors.
    a0 = cat(3, a0, nan([size(a0), S.Ahead-1]));
    pe = cat(3, pe, nan([size(pe), S.Ahead-1]));
    y0 = cat(3, y0, nan([size(y0), S.Ahead-1]));
    if S.retPred
        % `f0` exists and its k-step-ahead predictions need to be calculated only
        % if `pred` data are requested.
        f0 = permute(S.f0, [1, 3, 4, 2]);
        f0 = cat(3, f0, nan([size(f0), S.Ahead-1]));
    end

    numOfPeriods = size(S.y1, 2);
    bsxfunKa = size(S.ka, 2)==1;
    bsxfunD = size(S.d, 2)==1;
    for k = 2 : min(S.Ahead, numOfPeriods-1)
        t = 1+k : numOfPeriods;
        repeat = ones(1, numel(t));
        a0(:, t, k) = S.Ta*a0(:, t-1, k-1);
        if ~isempty(S.ka)
            if bsxfunKa
                a0(:, t, k) = bsxfun(@plus, a0(:, t, k), S.ka);
            else
                a0(:, t, k) = a0(:, t, k) + S.ka(:, t);
            end
        end
        y0(:, t, k) = S.Z*a0(:, t, k);
        if ~isempty(S.d)
            if bsxfunD
                y0(:, t, k) = bsxfun(@plus, y0(:, t, k), S.d);
            else
                y0(:, t, k) = y0(:, t, k) + S.d(:, t);
            end
        end
        if S.retPred
            f0(:, t, k) = S.Tf*a0(:, t-1, k-1);
            if ~isempty(S.kf)
                if ~S.IsShkTune
                    f0(:, t, k) = f0(:, t, k) + S.kf(:, repeat);
                else
                    f0(:, t, k) = f0(:, t, k) + S.kf(:, t);
                end
            end
        end
    end
    if S.NPOut>0
        y0(:, :, 2:end) = y0(:, :, 2:end) + ydelta(:, :, ones(1, S.Ahead-1));
    end
    pe(:, :, 2:end) = S.y1(:, :, ones(1, S.Ahead-1)) - y0(:, :, 2:end);

    S.a0 = ipermute(a0, [1, 3, 4, 2]);
    S.pe = ipermute(pe, [1, 3, 4, 2]);
    S.y0 = ipermute(y0, [1, 3, 4, 2]);
    S.ydelta = ipermute(ydelta, [1, 3, 4, 2]);
    if S.retPred
        S.f0 = ipermute(f0, [1, 3, 4, 2]);
    end
end%




function S = getPredXfMean(S)
% getPredXfMean  Point prediction step for fwl transition variables. The
% MSE matrices are computed in `xxSmoothMse` only when needed.
    nf = size(S.Tf, 1);
    numOfPeriods = size(S.y1, 2);

    % Pre-allocate state vectors.
    if nf==0
        return
    end

    for t = 2 : numOfPeriods
        % Prediction step.
        jy1 = S.yindex(:, t-1);
        S.f0(:, 1, t) = S.Tf*(S.a0(:, 1, t-1) + S.K1(:, jy1, t-1)*S.pe(jy1, 1, t-1, 1));
        if ~isempty(S.kf)
            S.f0(:, 1, t) = S.f0(:, 1, t) + S.kf(:, min(t, end));
        end
    end
end%




function S = getFilterMean(S)
    nb = size(S.Ta, 1);
    nf = size(S.Tf, 1);
    ne = size(S.Ra, 2);
    numOfPeriods = size(S.y1, 2);
    yInx = S.yindex;
    lastObs = S.LastObs;

    % Pre-allocation. Re-use first page of prediction data. Prediction data
    % can have multiple pages if `ahead`>1.
    S.b1 = nan(nb, numOfPeriods);
    S.f1 = nan(nf, numOfPeriods);
    S.e1 = nan(ne, numOfPeriods);
    % Note that `S.y1` already exists.

    S.e1(:, 2:end) = 0;
    if lastObs<numOfPeriods
        S.b1(:, lastObs+1:end) = S.U*permute(S.a0(:, 1, lastObs+1:end, 1), [1, 3, 4, 2]);
        S.f1(:, lastObs+1:end) = S.f0(:, 1, lastObs+1:end, 1);
        S.y1(:, lastObs+1:end) = ipermute(S.y0(:, 1, lastObs+1:end, 1), [1, 3, 4, 2]);
    end

    for t = lastObs : -1 : 2
        j = yInx(:, t);
        d = [ ];
        if ~isempty(S.d)
            d = S.d(:, min(t, end));
        end
        [y1, f1, b1, e1] = ...
            kalman.oneStepBackMean(S, t, S.pe(:, 1, t, 1), S.a0(:, 1, t, 1), ...
            S.f0(:, 1, t, 1), S.ydelta(:, 1, t), d, 0);    
        S.y1(~j, t) = y1(~j, 1);
        if nf>0
            S.f1(:, t) = f1;
        end
        S.b1(:, t) = b1;
        S.e1(:, t) = e1;
    end
end%




function S = getFilterMse(S)
    % getFilterMse  MSE matrices for updating step.
    ny = size(S.Z, 1);
    nf = size(S.Tf, 1);
    nb = size(S.Ta, 1);
    ng = size(S.g, 1);
    numOfPeriods = size(S.y1, 2);
    lastObs = S.LastObs;

    % Pre-allocation.
    if S.retFilterMse
        S.Pb1 = nan(nb, nb, numOfPeriods);
    end
    S.Db1 = nan(nb, numOfPeriods); % Diagonal of Pb2.
    S.Df1 = nan(nf, numOfPeriods); % Diagonal of Pf2.
    S.Dy1 = nan(ny, numOfPeriods); % Diagonal of Py2.
    S.Dg1 = [nan(ng, 1), zeros(ng, numOfPeriods-1)];

    if lastObs<numOfPeriods
        if S.retFilterMse
            S.Pb1(:, :, lastObs+1:numOfPeriods) = S.Pb0(:, :, lastObs+1:numOfPeriods);
        end
        S.Dy1(:, lastObs+1:numOfPeriods) = S.Dy0(:, lastObs+1:numOfPeriods);
        S.Df1(:, lastObs+1:numOfPeriods) = S.Df0(:, lastObs+1:numOfPeriods);
        S.Db1(:, lastObs+1:numOfPeriods) = S.Db0(:, lastObs+1:numOfPeriods);
    end

    for t = lastObs : -1 : 2
        [Pb1, Dy1, Df1, Db1] = oneStepBackMse(S, t, 0);
        if S.retFilterMse
            S.Pb1(:, :, t) = Pb1;
        end
        S.Dy1(:, t) = Dy1;
        if nf>0 && t>1
            S.Df1(:, t) = Df1;
        end
        S.Db1(:, t) = Db1;
    end
end%




function S = getSmoothMse(S)
    % getSmoothMse  Smoother for MSE matrices of all variables.
    ny = size(S.Z, 1);
    nf = size(S.Tf, 1);
    nb = size(S.Ta, 1);
    ng = size(S.g, 1);
    numOfPeriods = size(S.y1, 2);
    lastSmooth = S.lastSmooth;
    lastObs = S.LastObs;

    % Pre-allocation.
    if S.retSmoothMse
        S.Pb2 = nan(nb, nb, numOfPeriods);
    end
    S.Db2 = nan(nb, numOfPeriods); % Diagonal of Pb2.
    S.Df2 = nan(nf, numOfPeriods); % Diagonal of Pf2.
    S.Dy2 = nan(ny, numOfPeriods); % Diagonal of Py2.
    S.Dg2 = [nan(ng, 1), zeros(ng, numOfPeriods-1)];

    if lastObs<numOfPeriods
        S.Pb2(:, :, lastObs+1:numOfPeriods) = S.Pb0(:, :, lastObs+1:numOfPeriods);
        S.Dy2(:, lastObs+1:numOfPeriods) = S.Dy0(:, lastObs+1:numOfPeriods);
        S.Df2(:, lastObs+1:numOfPeriods) = S.Df0(:, lastObs+1:numOfPeriods);
        S.Db2(:, lastObs+1:numOfPeriods) = S.Db0(:, lastObs+1:numOfPeriods);
    end

    N = 0;
    for t = lastObs : -1 : lastSmooth
        [Pb2, Dy2, Df2, Db2, N] = oneStepBackMse(S, t, N);
        if S.retSmoothMse
            S.Pb2(:, :, t) = Pb2;
        end
        S.Dy2(:, t) = Dy2;
        if nf>0 && t>lastSmooth
            S.Df2(:, t) = Df2;
        end
        S.Db2(:, t) = Db2;
    end
end%




function S = getSmoothMean(S)
    % getSmoothMean  Kalman smoother for point estimates of all variables.
    nb = size(S.Ta, 1);
    nf = size(S.Tf, 1);
    ne = size(S.Ra, 2);
    numOfPeriods = size(S.y1, 2);
    lastObs = S.LastObs;
    lastSmooth = S.lastSmooth;
    % Pre-allocation. Re-use first page of prediction data. Prediction data
    % can have multiple pages if ahead>1.
    S.b2 = S.U*permute(S.a0(:, 1, :, 1), [1, 3, 4, 2]);
    S.f2 = permute(S.f0(:, 1, :, 1), [1, 3, 4, 2]);
    S.e2 = zeros(ne, numOfPeriods);
    S.y2 = S.y1(:, :, 1);
    % No need to run the smoother beyond last observation.
    S.y2(:, lastObs+1:end) = permute(S.y0(:, 1, lastObs+1:end, 1), [1, 3, 4, 2]);
    r = zeros(nb, 1);
    for t = lastObs : -1 : lastSmooth
        j = S.yindex(:, t);
        d = [ ];
        if ~isempty(S.d)
            d = S.d(:, min(t, end));
        end
        [y2, f2, b2, e2, r] = ...
            kalman.oneStepBackMean(S, t, S.pe(:, 1, t, 1), S.a0(:, 1, t, 1), ...
            S.f0(:, 1, t, 1), S.ydelta(:, 1, t), d, r);
        S.y2(~j, t) = y2(~j, 1);
        if nf>0
            S.f2(:, t) = f2;
        end
        S.b2(:, t) = b2;
        S.e2(:, t) = e2;
    end
end%




function [D, Ka, Kf] = addShockTunes(s, R,  opt)
    % addShockTunes  Add tunes on shock means to constant terms
    ne = size(s.Ra, 2);
    ny = size(s.Z, 1);
    nf = size(s.Tf, 1);
    nb = size(s.Ta, 1);
    numOfPeriods = size(s.y1, 2);
    if opt.Deviation
        D = zeros(ny, numOfPeriods);
        Ka = zeros(nb, numOfPeriods);
        Kf = zeros(nf, numOfPeriods);
    else
        D = repmat(s.d, 1, numOfPeriods);
        Ka = repmat(s.ka, 1, numOfPeriods);
        Kf = repmat(s.kf, 1, numOfPeriods);
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




function s = convertOmg2SaSy(s, sx)
    % Convert the structural covariance matrix `Omg` to reduced-form
    % covariance matrices `Sa` and `Sy`. Detect `Inf` std deviations and remove
    % the corresponding observations.
    ny = size(s.Z, 1);
    nf = size(s.Tf, 1);
    nb = size(s.Ta, 1);
    ne = size(s.Ra, 2);
    numOfPeriods = size(s.y1, 2);
    lastOmg = size(s.Omg, 3);
    inxOfET = s.InxOfET;
    inxOfEM = s.InxOfEM;

    % Periods where Omg(t) is the same as Omg(t-1).
    omgEqual = [false, all(sx(:, 1:end-1)==sx(:, 2:end), 1)];

    % Cut off forward expansion.
    Ra = s.Ra(:, 1:ne);
    Rf = s.Rf(:, 1:ne);
    Ra = Ra(:, inxOfET);
    Rf = Rf(:, inxOfET);

    H = s.H(:, inxOfEM);
    Ht = s.H(:, inxOfEM).';

    s.Sa = nan(nb, nb, lastOmg);
    s.Sf = nan(nf, nf, lastOmg);
    s.Sfa = nan(nf, nb, lastOmg);
    s.Sy = nan(ny, ny, lastOmg);
    s.syinf = false(ny, lastOmg);

    for t = 1 : lastOmg
        % If Omg(t) is the same as Omg(t-1), do not compute anything and
        % only copy the previous results.
        if omgEqual(t)
            s.Sa(:, :, t) = s.Sa(:, :, t-1);
            s.Sf(:, :, t) = s.Sf(:, :, t-1);
            s.Sfa(:, :, t) = s.Sfa(:, :, t-1);
            s.Sy(:, :, t) = s.Sy(:, :, t-1);
            s.syinf(:, t) = s.syinf(:, t-1);
            continue
        end
        Omg = s.Omg(:, :, t);
        OmgT = Omg(inxOfET, inxOfET);
        OmgM = Omg(inxOfEM, inxOfEM);
        s.Sa(:, :, t) = Ra*OmgT*Ra.';
        s.Sf(:, :, t) = Rf*OmgT*Rf.';
        s.Sfa(:, :, t) = Rf*OmgT*Ra.';
        omgMInf = isinf(diag(OmgM));
        if ~any(omgMInf)
            % No `Inf` std devs.
            s.Sy(:, :, t) = H*OmgM*Ht;
        else
            % Some std devs are `Inf`, we will remove the corresponding observations.
            s.Sy(:, :, t) = ...
                H(:, ~omgMInf)*OmgM(~omgMInf, ~omgMInf)*Ht(~omgMInf, :);
            s.syinf(:, t) = diag(H(:, omgMInf)*Ht(omgMInf, :)) ~= 0;
        end
    end

    % Expand `syinf` in 2nd dimension to match the number of periods. This
    % is because we use `syinf` to remove observations from `y1` on the whole
    % filter range.
    if lastOmg<numOfPeriods
        s.syinf(:, end+1:numOfPeriods) = s.syinf(:, ones(1, numOfPeriods-lastOmg));
    end
end%


%
% Local Functions
%


function [Pb, Dy, Df, Db, N] = oneStepBackMse(S, T, N)
    % xxOneStepBackMse  One-step backward smoothing for MSE matrices.
    ny = size(S.Z, 1);
    nf = size(S.Tf, 1);
    lastSmooth = S.lastSmooth;
    j = S.yindex(:, T);
    U = S.U;

    if isempty(N) || all(N(:)==0)
        N = (S.Z(j, :).'/S.F(j, j, T))*S.Z(j, :);
    else
        N = (S.Z(j, :).'/S.F(j, j, T))*S.Z(j, :) + S.L(:, :, T).'*N*S.L(:, :, T);
    end

    Pa0NPa0 = S.Pa0(:, :, T)*N*S.Pa0(:, :, T);
    Pa = S.Pa0(:, :, T) - Pa0NPa0;
    Pa = (Pa + Pa')/2;
    Pb = kalman.pa2pb(U, Pa);
    Db = diag(Pb);

    if nf>0 && T>lastSmooth
        % Fwl transition variables.
        Pf = S.Pf0(:, :, T) - S.Pfa0(:, :, T)*N*S.Pfa0(:, :, T).';
        % Pfa2 = s.Pfa0(:, :, t) - Pfa0N*s.Pa0(:, :, t);
        Pf = (Pf + Pf')/2;
        Df = diag(Pf);
    else
        Df = nan(nf, 1);
    end

    if ny>0
        % Measurement variables.
        Py = S.F(:, :, T) - S.Z*Pa0NPa0*S.Z.';
        Py = (Py + Py')/2;
        Py(j, :) = 0;
        Py(:, j) = 0;
        Dy = diag(Py);
    end
end%
