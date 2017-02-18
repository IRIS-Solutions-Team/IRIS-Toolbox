function [obj, regOutp, hData] = kalmanFilter(this, inp, hData, opt, varargin)
% kalmanFilter  Run Kalman filter.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

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

[ny, nxx, nb, nf, ne, ng] = sizeOfSolution(this.Vector);
nAlt = length(this);
nData = size(inp, 3);

if ~isequal(opt.simulate, false)
    opt.simulate = passvalopt('model.simulate', opt.simulate{:});
end

%--------------------------------------------------------------------------

s = struct( );
s.EIGEN_TOLERANCE = this.Tolerance.Eigen;
s.DIFFUSE_SCALE = 1e8;
s.IsSimulate = ~isequal(opt.simulate, false) ...
    && strcmpi(opt.simulate.method, 'selective') ...
    && opt.simulate.NonlinWindow>0 && any(this.Equation.IxHash);
s.NAhead = opt.ahead;
s.IsObjOnly = nargout<=1;

% Out-of-lik params cannot be used with ~opt.dtrends.
nPOut = length(opt.outoflik);

% Extended number of periods including pre-sample.
nPer = size(inp, 2) + 1;

% Struct with currently processed information. Initialise the invariant
% fields.
s.ny = ny;
s.nx = nxx;
s.nb = nb;
s.nf = nf;
s.ne = ne;
s.NPOut = nPOut;

% Add pre-sample to objective function range and deterministic time trend.
s.IxObjRange = [false, opt.objrange];

% Do not adjust the option `'lastSmooth='` -- see comments in `loglikopt`.
s.lastSmooth = opt.lastsmooth;

% Tunes on shock means; model solution is expanded within `prepareLoglik`.
tune = opt.tune;
s.IsShkTune = ~isempty(tune) && any( tune(:)~=0 );
if s.IsShkTune
    % Add pre-sample.
    nTune = size(tune, 3);
    tune = [zeros(ne, 1, nTune), tune];
end

% Total number of cycles.
nLoop = max(nData, nAlt);
s.nPred = max(nLoop, s.NAhead);

% Pre-allocate output data.
if ~s.IsObjOnly
    requestOutp( );
end

% Pre-allocate the non-hdata output arguments.
nObj = 1;
if opt.objdecomp
    nObj = nPer;
end
obj = nan(nObj, nLoop, opt.precision);

if ~s.IsObjOnly
    % Regular (non-hdata) output arguments.
    regOutp = struct( );
    regOutp.F = nan(ny, ny, nPer, nLoop, opt.precision);
    regOutp.Pe = nan(ny, nPer, s.nPred, opt.precision);
    regOutp.V = nan(1, nLoop, opt.precision);
    regOutp.Delta = nan(nPOut, nLoop, opt.precision);
    regOutp.PDelta = nan(nPOut, nPOut, nLoop, opt.precision);
    regOutp.SampleCov = nan(ne, ne, nLoop);
    regOutp.NLoop = nLoop;
end

% Measurement and transition shocks within all shocks.
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
s.IxEm = this.Quantity.Type(ixe)==TYPE(31);
s.IxEt = this.Quantity.Type(ixe)==TYPE(32);

% Prepare struct and options for non-linear simulations (prediction
% step).
sn = struct( );
if s.IsSimulate
    prepareSimulate( );
end

% Main loop
%-----------

if ~s.IsObjOnly && opt.progress
    progress = ProgressBar('IRIS Model.kalmanFilter progress');
end

ixSolved = true(1, nAlt);
ixValidFactor = true(1, nLoop);

for iLoop = 1 : nLoop
    % Next data
    %-----------    
    % Measurement and exogenous variables, and initial observations of
    % measurement variables. Deterministic trends will be subtracted later on.
    s.y1 = inp(1:ny, :, min(iLoop, end));
    s.g = inp(ny+1:end, :, min(iLoop, end));
    
    % Add pre-sample initial condition.
    s.y1 = [nan(ny, 1), s.y1];
    s.g = [nan(ng, 1), s.g];
    
    % Next model solution
    %---------------------
    if iLoop<=nAlt
        T = this.solution{1}(:, :, iLoop);
        R = this.solution{2}(:, :, iLoop);
        s.Z = this.solution{4}(:, :, iLoop);
        s.H = this.solution{5}(:, :, iLoop);
        s.U = this.solution{7}(:, :, iLoop);
        s.IxRequired = this.Variant{iLoop}.IxInit(1, :, iLoop);
        s.NUnit = sum(this.Variant{iLoop}.Stability==TYPE(1));
        s.Tf = T(1:nf, :);
        s.Ta = T(nf+1:end, :);
        % Keep forward expansion for computing the effect of tunes on shock
        % means. Cut off the expansion within subfunctions.
        s.Rf = R(1:nf, :);
        s.Ra = R(nf+1:end, :);
        s.Zt = s.Z.';
        if opt.deviation
            s.ka = [ ];
            s.kf = [ ];
            s.d = [ ];
        else
            s.d = this.solution{6}(:, :, iLoop);
            k = this.solution{3}(:, 1, iLoop);
            s.kf = k(1:nf, :);
            s.ka = k(nf+1:end, :);
        end
        
        % Store `Expand` matrices only if there are tunes on mean of shocks.
        if ~s.IsShkTune
            s.Expand = [ ];
        else
            s.Expand = cell(size(this.Expand));
            for i = 1 : numel(s.Expand)
                s.Expand{i} = this.Expand{i}(:, :, min(iLoop, end));
            end
        end
        
        % Time-varying stdcorr
        %----------------------
        % Combine currently assigned `stdcorr` in the model object with the
        % user-supplied time-vaying `stdcorr`.
        stdcorri = this.Variant{iLoop}.StdCorr.';
        s.stdcorr = this.combineStdCorr(stdcorri, opt.stdcorr, nPer-1);
        
        % Add presample, which will be used to initialise the Kalman
        % filter.
        stdcorri = s.stdcorr(:,1);
        s.stdcorr = [stdcorri, s.stdcorr];
        
        % Create covariance matrix from stdcorr vector.
        s.Omg = covfun.stdcorr2cov(s.stdcorr, ne);
        
        % Create reduced form covariance matrices `Sa` and `Sy`, and find
        % measurement variables with infinite measurement shocks, `syinf`.
        s = convertOmg2SaSy(s);
        
        % Free memory.
        s.stdcorr = [ ];
    end
    
    % Continue immediately if solution is not available; report NaN solutions
    % post mortem.
    ixSolved(iLoop) = all(~isnan(T(:)));
    if ~ixSolved(iLoop)
        continue
    end
    
    % Deterministic trends
    %----------------------
    % y(t) - D(t) - X(t)*delta = Z*a(t) + H*e(t).
    if nPOut>0 || opt.dtrends
        [s.D, s.X] = evalDtrends(this, opt.outoflik, s.g, iLoop);
    else
        s.D = [ ];
        s.X = zeros(ny, 0, nPer);
    end
    % Subtract fixed deterministic trends from measurement variables
    if ~isempty(s.D)
        s.y1 = s.y1 - s.D;
    end

    % Next tunes on the means of the shocks
    %---------------------------------------
    % Add the effect of the tunes to the constant vector; recompute the
    % effect whenever the tunes have changed or the model solution has changed
    % or both.
    %
    % The std dev of the tuned shocks remain unchanged and hence the
    % filtered shocks can differ from its tunes (unless the user specifies zero
    % std dev).
    if s.IsShkTune
        s.tune = tune(:, :, min(iLoop, end));
        [s.d, s.ka, s.kf] = addShockTunes(s, opt);
    end
    
    % Make measurement variables with `Inf` measurement shocks look like
    % missing. The `Inf` measurement shocks are detected in `xxomg2sasy`.
    s.y1(s.syinf) = NaN;
    
    % Index of available observations.
    s.yindex = ~isnan(s.y1);
    s.lastObs = max( 0, find( any(s.yindex, 1), 1, 'last' ) );
    s.jyeq = [false, all(s.yindex(:, 2:end)==s.yindex(:, 1:end-1), 1) ];
    
    % Initialize
    %------------
    % * Initial distribution
    % * Number of init cond estimated as fixed unknowns
    s = kalman.init(s, iLoop, opt);
    
    % Prediction step
    %-----------------
    % Prepare the struct `s2` for nonlinear simulations in this round of
    % prediction steps.
    if s.IsSimulate
        sn.ILoop = iLoop;
        if iLoop<=nAlt
            sn = prepareSimulate2(this, sn, iLoop);
        end
    end
    
    % Run prediction error decomposition and evaluate user-requested
    % objective function.
    [obj(:, iLoop), s] = kalman.ped(s, sn, opt);
    ixValidFactor(iLoop) = abs(s.V)>MSE_TOLERANCE;

    % Return immediately if only the objective function is to be returned.
    if s.IsObjOnly
        continue
    end
    
    % Prediction errors uncorrected to estimated init cond and dtrends; these
    % are needed for contributions.
    if s.retCont
        s.peUnc = s.pe;
    end
    
    % Correct prediction errors for estimated initial conditions and dtrends
    % parameters.
    if s.NInit>0 || nPOut>0
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
    if s.NAhead>1 && s.storePredict
        s = goAhead(s);
    end
    
    % Updating step
    %---------------    
    if s.retFilter
        if s.retFilterStd || s.retFilterMse
            s = getFilterMse(s);
        end
        s = getFilterMean(s);
    end
    
    % Smoother
    %----------
    % Run smoother for all variables.
    if s.retSmooth
        if s.retSmoothStd || s.retSmoothMse
            s = getSmoothMse(s);
        end
        s = getSmoothMean(s);
    end
    
    % Contributions of measurement variables
    %----------------------------------------
    if s.retCont
        s = kalman.cont(s);
    end
    
    % Return requested data
    %-----------------------
    % Columns in `pe` to be filled.
    if s.NAhead>1
        predCols = 1 : s.NAhead;
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
    
    % Update progress bar
    %---------------------
    if opt.progress
        update(progress, iLoop/nLoop);
    end
    
end % for iLoop...

if ~all(ixSolved)
    throw( ...
        exception.Base('Model:SolutionNotAvailable', 'warning'), ...
        exception.Base.alt2str(~ixSolved) ...
        ); %#ok<GTARG>
end

if any(~ixValidFactor)
    throw( ...
        exception.Base('Model:ZeroVarianceFactor', 'warning'), ...
        exception.Base.alt2str(~ixValidFactor) ...
        ); %#ok<GTARG>        
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
        s.storePredict = s.NAhead>1 || s.retPred || s.retFilter || s.retSmooth;
    end



    
    function returnPred( )
        % Return pred mean.
        % Note that s.y0, s.f0 and s.a0 include k-sted-ahead predictions if
        % ahead>1.
        if s.retPredMean
            yy = permute(s.y0, [1, 3, 4, 2]);
            % Convert `alpha` predictions to `xb` predictions. The
            % `a0` may contain k-step-ahead predictions in 3rd dimension.
            bb = permute(s.a0, [1, 3, 4, 2]);
            for ii = 1 : size(bb, 3)
                bb(:, :, ii) = s.U*bb(:, :, ii);
            end
            ff = permute(s.f0, [1, 3, 4, 2]);
            xx = [ff;bb];
            % Shock predictions are always zeros.
            ee = zeros(ne, nPer, s.NAhead);
            % Set predictions for the pre-sample period to `NaN`.
            yy(:, 1, :) = NaN;
            xx(:, 1, :) = NaN;
            ee(:, 1, :) = NaN;
            % Add fixed deterministic trends back to measurement vars.
            if ~isempty(s.D)
                yy = yy + repmat(s.D, 1, 1, s.NAhead);
            end
            % Add shock tunes to shocks.
            if s.IsShkTune
                ee = ee + repmat(s.tune, 1, 1, s.NAhead);
            end
            % Do not use lags in the prediction output data.
            hdataassign(hData.M0, predCols, { yy, xx, ee, [ ], [ ] } );
        end
        
        % Return pred std.
        if s.retPredStd
            % Do not use lags in the prediction output data.
            hdataassign(hData.S0, iLoop, ...
                {s.Dy0*s.V, ...
                [s.Df0;s.Db0]*s.V, ...
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
            yy = s.yc0;
            yy = permute(yy, [1, 3, 2, 4]);
            xx = [s.fc0;s.bc0];
            xx = permute(xx, [1, 3, 2, 4]);
            xx(:, 1, :) = NaN;
            ee = s.ec0;
            ee = permute(ee, [1, 3, 2, 4]);
            gg = [nan(ng, 1), zeros(ng, nPer-1)];
            hdataassign(hData.predcont, ':', { yy, xx, ee, [ ], gg } );
        end
    end 




    function returnFilter( )        
        if s.retFilterMean
            yy = s.y1;
            xx = [s.f1; s.b1];
            ee = s.e1;
            % Add fixed deterministic trends back to measurement vars.
            if ~isempty(s.D)
                yy = yy + s.D;
            end
            % Add shock tunes to shocks.
            if s.IsShkTune
                ee = ee + s.tune;
            end
            % Do not use lags in the filter output data.
            hdataassign(hData.M1, iLoop, { yy, xx, ee, [ ], s.g } );
        end
        
        % Return PE contributions to filter step.
        if s.retFilterCont
            yy = s.yc1;
            yy = permute(yy, [1, 3, 2, 4]);
            xx = [s.fc1; s.bc1];
            xx = permute(xx, [1, 3, 2, 4]);
            ee = s.ec1;
            ee = permute(ee, [1, 3, 2, 4]);
            gg = [nan(ng, 1), zeros(ng, nPer-1)];
            hdataassign(hData.filtercont, ':', { yy, xx, ee, [ ], gg } );
        end
        
        % Return filter std.
        if s.retFilterStd
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
    end 




    function returnSmooth( )
        if s.retSmoothMean
            yy = s.y2;
            xx = [s.f2;s.b2(:, :, 1)];
            yy(:, 1:s.lastSmooth) = NaN;
            xx(:, 1:s.lastSmooth-1) = NaN;
            xx(1:nf, s.lastSmooth) = NaN;
            % Add deterministic trends to measurement vars.
            if ~isempty(s.D)
                yy = yy + s.D;
            end
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
            s.Dy2(:, 1:s.lastSmooth) = NaN;
            s.Df2(:, 1:s.lastSmooth) = NaN;
            s.Db2(:, 1:s.lastSmooth-1) = NaN;
            hdataassign(hData.S2, iLoop, ...
                { ...
                s.Dy2*s.V, ...
                [s.Df2;s.Db2]*s.V, ...
                [ ], ...
                [ ], ...
                s.Dg2*s.V, ...
                });
        end
        
        % Return PE contributions to smooth step.
        if s.retSmoothCont
            yy = s.yc2;
            yy = permute(yy, [1, 3, 2, 4]);
            xx = [s.fc2;s.bc2];
            xx = permute(xx, [1, 3, 2, 4]);
            ee = s.ec2;
            ee = permute(ee, [1, 3, 2, 4]);
            gg = [nan(ng, 1), zeros(ng, nPer-1)];
            hdataassign(hData.C2, ':', { yy, xx, ee, [ ], gg } );
        end
        
        ixObjRange = s.IxObjRange & any(s.yindex, 1);
        s.SampleCov = ee(:, ixObjRange)*ee(:, ixObjRange).'/sum(ixObjRange);
        
        % Return smooth MSE for `xb`.
        if s.retSmoothMse
            s.Pb2(:, :, 1:s.lastSmooth-1) = NaN;
            hData.Mse2.Data(:, :, :, iLoop) = s.Pb2*s.V;
        end
    end




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
        sn = prepareSimulate1(this, sn, opt.simulate);
    end
end




function S = goAhead(S)
% goAhead  K-step ahead predictions and prediction errors for K>2 when
% requested by caller. This function must be called after correction for
% diffuse initial conditions and/or out-of-lik params has been made.

a0 = permute(S.a0, [1, 3, 4, 2]);
pe = permute(S.pe, [1, 3, 4, 2]);
y0 = permute(S.y0, [1, 3, 4, 2]);
ydelta = permute(S.ydelta, [1, 3, 4, 2]);

% Expand existing prediction vectors.
a0 = cat(3, a0, nan([size(a0), S.NAhead-1]));
pe = cat(3, pe, nan([size(pe), S.NAhead-1]));
y0 = cat(3, y0, nan([size(y0), S.NAhead-1]));
if S.retPred
    % `f0` exists and its k-step-ahead predictions need to be calculated only
    % if `pred` data are requested.
    f0 = permute(S.f0, [1, 3, 4, 2]);
    f0 = cat(3, f0, nan([size(f0), S.NAhead-1]));
end

nPer = size(S.y1, 2);
for k = 2 : min(S.NAhead, nPer-1)
    t = 1+k : nPer;
    repeat = ones(1, numel(t));
    a0(:, t, k) = S.Ta*a0(:, t-1, k-1);
    if ~isempty(S.ka)
        if ~S.IsShkTune
            a0(:, t, k) = a0(:, t, k) + S.ka(:, repeat);
        else
            a0(:, 1, t, k) = a0(:, t, k) + S.ka(:, t);
        end
    end
    y0(:, t, k) = S.Z*a0(:, t, k);
    if ~isempty(S.d)
        if ~S.IsShkTune
            y0(:, t, k) = y0(:, t, k) + S.d(:, repeat);
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
    y0(:, :, 2:end) = y0(:, :, 2:end) + ydelta(:, :, ones(1, S.NAhead-1));
end
pe(:, :, 2:end) = S.y1(:, :, ones(1, S.NAhead-1)) - y0(:, :, 2:end);

S.a0 = ipermute(a0, [1, 3, 4, 2]);
S.pe = ipermute(pe, [1, 3, 4, 2]);
S.y0 = ipermute(y0, [1, 3, 4, 2]);
S.ydelta = ipermute(ydelta, [1, 3, 4, 2]);
if S.retPred
    S.f0 = ipermute(f0, [1, 3, 4, 2]);
end

end 




function S = getPredXfMean(S)
% getPredXfMean  Point prediction step for fwl transition variables. The
% MSE matrices are computed in `xxSmoothMse` only when needed.
nf = size(S.Tf, 1);
nPer = size(S.y1, 2);

% Pre-allocate state vectors.
if nf==0
    return
end

for t = 2 : nPer
    % Prediction step.
    jy1 = S.yindex(:, t-1);
    S.f0(:, 1, t) = S.Tf*(S.a0(:, 1, t-1) + S.K1(:, jy1, t-1)*S.pe(jy1, 1, t-1, 1));
    if ~isempty(S.kf)
        S.f0(:, 1, t) = S.f0(:, 1, t) + S.kf(:, min(t, end));
    end
end
end




function S = getFilterMean(S)
nb = size(S.Ta, 1);
nf = size(S.Tf, 1);
ne = size(S.Ra, 2);
nPer = size(S.y1, 2);
yInx = S.yindex;
lastObs = S.lastObs;

% Pre-allocation. Re-use first page of prediction data. Prediction data
% can have multiple pages if `ahead`>1.
S.b1 = nan(nb, nPer);
S.f1 = nan(nf, nPer);
S.e1 = nan(ne, nPer);
% Note that `S.y1` already exists.

S.e1(:, 2:end) = 0;
if lastObs<nPer
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
end




function S = getFilterMse(S)
% getFilterMse  MSE matrices for updating step.
ny = size(S.Z, 1);
nf = size(S.Tf, 1);
nb = size(S.Ta, 1);
ng = size(S.g, 1);
nPer = size(S.y1, 2);
lastObs = S.lastObs;

% Pre-allocation.
if S.retFilterMse
    S.Pb1 = nan(nb, nb, nPer);
end
S.Db1 = nan(nb, nPer); % Diagonal of Pb2.
S.Df1 = nan(nf, nPer); % Diagonal of Pf2.
S.Dy1 = nan(ny, nPer); % Diagonal of Py2.
S.Dg1 = [nan(ng, 1), zeros(ng, nPer-1)];

if lastObs<nPer
    if S.retFilterMse
        S.Pb1(:, :, lastObs+1:nPer) = S.Pb0(:, :, lastObs+1:nPer);
    end
    S.Dy1(:, lastObs+1:nPer) = S.Dy0(:, lastObs+1:nPer);
    S.Df1(:, lastObs+1:nPer) = S.Df0(:, lastObs+1:nPer);
    S.Db1(:, lastObs+1:nPer) = S.Db0(:, lastObs+1:nPer);
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
end




function S = getSmoothMse(S)
% getSmoothMse  Smoother for MSE matrices of all variables.
ny = size(S.Z, 1);
nf = size(S.Tf, 1);
nb = size(S.Ta, 1);
ng = size(S.g, 1);
nPer = size(S.y1, 2);
lastSmooth = S.lastSmooth;
lastObs = S.lastObs;

% Pre-allocation.
if S.retSmoothMse
    S.Pb2 = nan(nb, nb, nPer);
end
S.Db2 = nan(nb, nPer); % Diagonal of Pb2.
S.Df2 = nan(nf, nPer); % Diagonal of Pf2.
S.Dy2 = nan(ny, nPer); % Diagonal of Py2.
S.Dg2 = [nan(ng, 1), zeros(ng, nPer-1)];

if lastObs<nPer
    S.Pb2(:, :, lastObs+1:nPer) = S.Pb0(:, :, lastObs+1:nPer);
    S.Dy2(:, lastObs+1:nPer) = S.Dy0(:, lastObs+1:nPer);
    S.Df2(:, lastObs+1:nPer) = S.Df0(:, lastObs+1:nPer);
    S.Db2(:, lastObs+1:nPer) = S.Db0(:, lastObs+1:nPer);
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
end 




function S = getSmoothMean(S)
% getSmoothMean  Kalman smoother for point estimates of all variables.
nb = size(S.Ta, 1);
nf = size(S.Tf, 1);
ne = size(S.Ra, 2);
nPer = size(S.y1, 2);
lastObs = S.lastObs;
lastSmooth = S.lastSmooth;

% Pre-allocation. Re-use first page of prediction data. Prediction data
% can have multiple pages if ahead>1.
S.b2 = S.U*permute(S.a0(:, 1, :, 1), [1, 3, 4, 2]);
S.f2 = permute(S.f0(:, 1, :, 1), [1, 3, 4, 2]);
S.e2 = zeros(ne, nPer);
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
end 




function [D, Ka, Kf] = addShockTunes(s, opt)
% addShockTunes  Add tunes on shock means to constant terms.
FN_FIND_LAST = @(x) max([ 0, find(any(any(x, 3), 1), 1, 'last') ]);

ne = size(s.Ra, 2);
if ne==0
    return
end

ny = size(s.Z, 1);
nf = size(s.Tf, 1);
nb = size(s.Ta, 1);
nPer = size(s.y1, 2);

if opt.deviation
    D = zeros(ny, nPer);
    Ka = zeros(nb, nPer);
    Kf = zeros(nf, nPer);
else
    D = s.d(:, ones(1, nPer));
    Ka = s.ka(:, ones(1, nPer));
    Kf = s.kf(:, ones(1, nPer));
end

eu = real(s.tune);
ea = imag(s.tune);
eu(isnan(eu)) = 0;
ea(isnan(ea)) = 0;

lastAnt = FN_FIND_LAST(ea~=0);
lastUnant = FN_FIND_LAST(eu~=0);
last = max(lastAnt, lastUnant);
if isempty(last) || last<2
    return
end

Rf = s.Rf;
Ra = s.Ra;
if lastAnt>0
    R = [Rf;Ra];
    R = model.myexpand(R, [ ], lastAnt, s.Expand{:});
    Rf = R(1:nf, :);
    Ra = R(nf+1:end, :);
end
H = s.H;

for t = 2 : last
    ee = [eu(:, t) + ea(:, t), ea(:, t+1:lastAnt)];
    k = size(ee, 2);
    D(:, t) = D(:, t) + H*ee(:, 1);
    Kf(:, t) = Kf(:, t) + Rf(:, 1:ne*k)*ee(:);
    Ka(:, t) = Ka(:, t) + Ra(:, 1:ne*k)*ee(:);
end
end 




function S = convertOmg2SaSy(S)
% Convert the structural covariance matrix `Omg` to reduced-form
% covariance matrices `Sa` and `Sy`. Detect `Inf` std deviations and remove
% the corresponding observations.
ny = size(S.Z, 1);
nf = size(S.Tf, 1);
nb = size(S.Ta, 1);
ne = size(S.Ra, 2);
nPer = size(S.y1, 2);
lastOmg = size(S.Omg, 3);
ixet = S.IxEt;
ixem = S.IxEm;

% Periods where Omg(t) is the same as Omg(t-1).
omgEqual = [false, all(S.stdcorr(:, 1:end-1)==S.stdcorr(:, 2:end), 1)];

% Cut off forward expansion.
Ra = S.Ra(:, 1:ne);
Rf = S.Rf(:, 1:ne);
Ra = Ra(:, ixet);
Rf = Rf(:, ixet);

H = S.H(:, ixem);
Ht = S.H(:, ixem).';

S.Sa = nan(nb, nb, lastOmg);
S.Sf = nan(nf, nf, lastOmg);
S.Sfa = nan(nf, nb, lastOmg);
S.Sy = nan(ny, ny, lastOmg);
S.syinf = false(ny, lastOmg);

for t = 1 : lastOmg
    % If Omg(t) is the same as Omg(t-1), do not compute anything and
    % only copy the previous results.
    if omgEqual(t)
        S.Sa(:, :, t) = S.Sa(:, :, t-1);
        S.Sf(:, :, t) = S.Sf(:, :, t-1);
        S.Sfa(:, :, t) = S.Sfa(:, :, t-1);
        S.Sy(:, :, t) = S.Sy(:, :, t-1);
        S.syinf(:, t) = S.syinf(:, t-1);
        continue
    end
    Omg = S.Omg(:, :, t);
    OmgT = Omg(ixet, ixet);
    OmgM = Omg(ixem, ixem);
    S.Sa(:, :, t) = Ra*OmgT*Ra.';
    S.Sf(:, :, t) = Rf*OmgT*Rf.';
    S.Sfa(:, :, t) = Rf*OmgT*Ra.';
    omgMInf = isinf(diag(OmgM));
    if ~any(omgMInf)
        % No `Inf` std devs.
        S.Sy(:, :, t) = H*OmgM*Ht;
    else
        % Some std devs are `Inf`, we will remove the corresponding observations.
        S.Sy(:, :, t) = ...
            H(:, ~omgMInf)*OmgM(~omgMInf, ~omgMInf)*Ht(~omgMInf, :);
        S.syinf(:, t) = diag(H(:, omgMInf)*Ht(omgMInf, :)) ~= 0;
    end
end

% Expand `syinf` in 2nd dimension to match the number of periods. This
% is because we use `syinf` to remove observations from `y1` on the whole
% filter range.
if lastOmg<nPer
    S.syinf(:, end+1:nPer) = S.syinf(:, ones(1, nPer-lastOmg));
end
end




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
Pa = (Pa + Pa.')/2;
Pb = kalman.pa2pb(U, Pa);
Db = diag(Pb);

if nf>0 && T>lastSmooth
    % Fwl transition variables.
    Pf = S.Pf0(:, :, T) - S.Pfa0(:, :, T)*N*S.Pfa0(:, :, T).';
    % Pfa2 = s.Pfa0(:, :, t) - Pfa0N*s.Pa0(:, :, t);
    Pf = (Pf + Pf.')/2;
    Df = diag(Pf);
else
    Df = nan(nf, 1);
end

if ny>0
    % Measurement variables.
    Py = S.F(:, :, T) - S.Z*Pa0NPa0*S.Z.';
    Py = (Py + Py.')/2;
    Py(j, :) = 0;
    Py(:, j) = 0;
    Dy = diag(Py);
end
end
