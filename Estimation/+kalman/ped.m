function [obj, s] = ped(s, sn, opt)
% ped  Prediction error decomposition and objective function evaluation
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

ny = size(s.Z, 1);
nb = size(s.Ta, 1);
nf = size(s.Tf, 1);
ne = size(s.Ra, 2);
ng = size(s.g, 1);
nPer = size(s.y1, 2);
lastOmg = size(s.Omg, 3);

nPOut = s.NPOut; % Number of dtrend params concentrated out of lik function.
nInit = s.NInit; % Number of init conditions estimated as fixed unknowns.

y1 = s.y1;
Ta = s.Ta;
Tat = s.Ta.';
Tf = s.Tf;
ka = s.ka;
d = s.d;
jy = false(ny, 1);
Z = s.Z(jy, :);
X = s.X;

K0 = zeros(nb, 0);
K1 = zeros(nb, 0);
pe = zeros(0, 1);
ZP = zeros(0, nb);

% Objective function.
obj = NaN;
if opt.objdecomp
    obj = nan(1, nPer);
end

% Initialise objective function components.
peFipe = zeros(1, nPer);
logdetF = zeros(1, nPer);

% Effect of outofliks and fixed init states on a(t).
Q1 = zeros(nb, nPOut);
Q2 = eye(nb, nInit);
% Effect of outofliks and fixed init states on pe(t).
M1 = zeros(0, nPOut);
M2 = zeros(0, nInit);

% Initialise flags.
isPout = nPOut > 0;
isInit = nInit > 0;
isEst = isPout || isInit;

% Initialise sum terms used in out-of-lik estimation.
MtFiM = zeros(nPOut+nInit, nPOut+nInit, nPer);
MtFipe = zeros(nPOut+nInit, nPer);

% Initialise matrices that are to be stored.
if ~s.IsObjOnly

    % `pe` is allocated as an ny-by-1-by-nPer array because we re-use the same
    % algorithm for both regular runs of the filter and the contributions.
    s.pe = nan(ny, 1, nPer);
    
    s.F = nan(ny, ny, nPer);
    s.FF = nan(ny, ny, nPer);
    s.Fd = nan(1, nPer);
    s.M = nan(ny, nPOut+nInit, nPer);
    
    if s.storePredict
        % `a0`, `y0`, `ydelta` are allocated as an ny-by-1-by-nPer array because we
        % re-use the same algorithm for both regular runs of the filter and the
        % contributions.
        s.a0 = nan(nb, 1, nPer);
        s.a0(:, 1, 1) = s.InitMean;
        s.y0 = nan(ny, 1, nPer);
        s.ydelta = zeros(ny, 1, nPer);
        s.f0 = nan(nf, 1, nPer);
        
        s.Pa0 = nan(nb, nb, nPer);
        s.Pa1 = nan(nb, nb, nPer);
        s.Pa0(:, :, 1) = s.InitMse;
        s.Pa1(:, :, 1) = s.InitMse;
        s.De0 = nan(ne, nPer);
        % Kalman gain matrices.
        s.K0 = nan(nb, ny, nPer);
        s.K1 = nan(nb, ny, nPer);
        s.Q = zeros(nb, nPOut+nInit, nPer);
        s.Q(:, nPOut+1:end, 1) = Q2;
        if s.retSmooth
            s.L = nan(nb, nb, nPer);
            s.L(:, :, 1) = Ta;
        end
    end
    if s.retFilter || s.retSmooth
        s.Pf0 = nan(nf, nf, nPer);
        s.Pfa0 = nan(nf, nb, nPer);
    end
    if s.retPredStd || s.retFilterStd || s.retSmoothStd ...
            || s.retFilterMse || s.retSmoothMse
        s.Pb0 = nan(nb, nb, nPer);
        s.Dy0 = nan(ny, nPer);
        s.Df0 = nan(nf, nPer);
        s.Db0 = nan(nb, nPer);
    end
    if s.retCont
        s.MtFi = nan(nPOut+nInit, ny, nPer);
    end
end

% Reset initial condition.
a = s.InitMean;
P = s.InitMse;

% Number of actually observed data points.
numOfObs = zeros(1, nPer);

status = 'ok';

% Main loop
%-----------
for t = 2 : nPer

    % Effect of out-of-liks on `a(t)`
    %---------------------------------
    % Effect of outofliks on `a(t)`. This step must be made before
    % updating `jy` because we use `Ta(t-1)` and `K0(t-1)`.
    if isPout
        Q1 = Ta*Q1 - K0*M1(jy, :);
    end
    
    % Effect of fixed init states on `a(t)`. This step must be made
    % before updating `jy` because we use `Ta(t-1)` and `K0(t-1)`.
    if isInit
        Q2 = Ta*Q2 - K0*M2(jy, :);
    end
    
    % Prediction step t|t-1 for the alpha vector
    %--------------------------------------------
    % Mean prediction `a(t|t-1)`.
    if ~s.IsSimulate
        % Prediction `a(t|t-1)` based on `a(t-1|t-2)`, prediction error `pe(t-1)`, 
        % the transition matrix `Ta(t-1)`, and the Kalman gain `K0(t-1)`.
        a = Ta*a + K0*pe;
        % Adjust the prediction step for the constant vector.
        if ~isempty(ka)
            if ~s.IsShkTune
                a = a + ka;
            else
                a = a + ka(:, t);
            end
        end
    else
        % Run non-linear simulation to produce the mean prediction.
        simulatePredict( );
    end

    % Reduced-form shock covariance at time t.
    tOmg = min(t, lastOmg);
    Omg = s.Omg(:, :, tOmg);
    Sa = s.Sa(:, :, tOmg);
    Sy = s.Sy(:, :, tOmg);
    
    % MSE P(t|t-1) based on P(t-1|t-2), the predictive Kalman gain `K0(t-1)`, and
    % and the reduced-form covariance matrix Sa(t). Make sure P is numerically
    % symmetric and does not explode over time.
    P = (Ta*P - K0*ZP)*Tat + Sa;
    P = (P + P')/2;
    
    % Prediction step t|t-1 for measurement variables
    %-------------------------------------------------
    % Index of observations available at time t, `jy`, and index of
    % conditioning observables available at time t, `cy`.
    jy = s.yindex(:, t);
    cy = jy & opt.condition(:);
    isCondition = any(cy);
    
    % Z matrix at time t.
    Z = s.Z(jy, :);
    ZP = Z*P;
    PZt = ZP.';
    
    % Mean prediction for observables available, y0(t|t-1).
    y0 = Z*a;
    if ~isempty(d)
        td = min(t, size(d, 2));
        y0 = y0 + d(jy, td);
    end
    
    % Prediction MSE, `F(t|t-1)`, for observables available at time t; the size
    % of `F` changes over time.
    F = Z*PZt + Sy(jy, jy);
    
    % Prediction errors for the observables available, `pe(t)`. The size of
    % `pe` changes over time.
    pe = y1(jy, t) - y0;
    
    if opt.chkfmse
        % Only evaluate the cond number if the test is requested by the user.
        condNumber = rcond(F);
        if condNumber<opt.fmsecondtol || isnan(condNumber)
            status = 'condNumberFailed';
            break
        end
    end
    
    % Kalman gain matrices.
    K1 = PZt/F; % Gain in the updating step.
    K0 = Ta*K1; % Gain in the next prediction step.
    
    % Effect of out-of-liks on `-pe(t)`
    %-----------------------------------
    if isEst
        M1 = s.Z*Q1 + X(:, :, t);
        M2 = s.Z*Q2;
        M = [M1, M2];
    end
    
    % Objective function components
    %-------------------------------
    if s.IxObjRange(t)
        % The following variables may change in `doCond`, but we need to store the
        % original values in `doStorePed`.
        pex = pe;
        Fx = F;
        xy = jy;
        if isEst
            Mx = M(xy, :);
        end
        
        if isCondition
            % Condition the prediction step.
            condition( );
        end
        
        if isEst
            Mxt = Mx.';
            if opt.ObjFunc==1
                MtFi = Mxt/Fx;
            elseif opt.ObjFunc==2
                W = opt.weighting(xy, xy);
                MtFi = Mxt*W;
            else
                MtFi = 0;
            end
            MtFipe(:, t) = MtFi*pex;
            MtFiM(:, :, t) = MtFi*Mx;
        end
        
        % Compute components of the objective function if this period is included
        % in the user specified objective range.
        numOfObs(1, t) = sum(double(xy));
        if opt.ObjFunc==1
            % Likelihood function.
            peFipe(1, t) = (pex.'/Fx)*pex;
            logdetF(1, t) = log(det(Fx));
        elseif opt.ObjFunc==2
            % Weighted sum of prediction errors.
            W = opt.weighting(xy, xy);
            peFipe(1, t) = pex.'*W*pex;
        end
    end
    
    if ~s.IsObjOnly
        % Store prediction error decomposition.
        storePed( );
    end
    
end % for t...


switch status
    case 'condNumberFailed'
        obj(1) = s.ObjFunPenalty;
        V = 1;
        est = nan(nPOut+nInit, 1);
        Pest = nan(nPOut+nInit);
    otherwise % status=='ok'
        % Evaluate common variance scalar, out-of-lik parameters, fixed init
        % conditions, and concentrated likelihood function.
        [obj, V, est, Pest] = kalman.oolik(logdetF, peFipe, MtFiM, MtFipe, numOfObs, opt);
end

% Store estimates of out-of-lik parameters, `delta`, cov matrix of
% estimates of out-of-lik parameters, `Pdelta`, fixed init conditions, 
% `init`, and common variance scalar, `V`.
s.delta = est(1:nPOut, :);
s.PDelta = Pest(1:nPOut, 1:nPOut);
s.init = est(nPOut+1:end, :);
s.V = V;

if ~s.IsObjOnly && s.retCont
    if isEst
        s.sumMtFiM = sum(MtFiM, 3);
    else
        s.sumMtFiM = [ ];   
    end
end

return

    
    

    function storePed( )
        % doStorePed  Store predicition error decomposition.
        s.F(jy, jy, t) = F;
        s.pe(jy, 1, t) = pe;
        if isEst
            s.M(:, :, t) = M;
        end
        if s.storePredict
            storePredict( );
        end
    end%

    
    
    function storePredict( )
        % doStorePredict  Store prediction and updating steps.
        s.a0(:, 1, t) = a;
        s.Pa0(:, :, t) = P;
        s.Pa1(:, :, t) = P - K1*ZP;
        s.De0(:, t) = diag(Omg);
        % Compute mean and MSE for all measurement variables, not only
        % for the currently observed ones when predict data are returned.
        s.y0(:, 1, t) = s.Z*a;
        if ~isempty(d)
            s.y0(:, 1, t) = s.y0(:, 1, t) + d(:, td);
        end
        s.F(:, :, t) = s.Z*P*s.Z.' + Sy;
        s.FF(jy, jy, t) = F;
        s.K0(:, jy, t) = K0;
        s.K1(:, jy, t) = K1;
        s.Q(:, :, t) = [Q1, Q2];
        if s.retSmooth
            s.L(:, :, t) = Ta - K0*Z;
        end
        % Predict fwl variables.
        TfPa1 = Tf*s.Pa1(:, :, t-1);
        Pf0 = TfPa1*Tf.' + s.Sf(:, :, min(t, end));
        Pf0 = (Pf0 + Pf0')/2;
        if s.retFilter || s.retSmooth
            s.Pf0(:, :, t) = Pf0;
            Pfa0 = TfPa1*Ta.' + s.Sfa(:, :, min(t, end));
            s.Pfa0(:, :, t) = Pfa0;
        end
        if s.retPredStd || s.retFilterStd || s.retSmoothStd ...
                || s.retFilterMse || s.retSmoothMse
            s.Pb0(:, :, t) = kalman.pa2pb(s.U, P);
            s.Dy0(:, t) = diag(s.F(:, :, t));
            if nf>0
                s.Df0(:, t) = diag(Pf0);
            end
            s.Db0(:, t) = diag(s.Pb0(:, :, t));
        end
        if isEst && s.retCont
            s.MtFi(:, xy, t) = MtFi;
        end
    end%

    
    
    function simulatePredict( )
        % Simulate nonlinear predictions.
        a1 = a + K1*pe;
        sn.Alp0 = a1;
        sn.ZerothSegment = t - 2;
        [~, ~, ~, ~, w] = simulate.selective.run(sn);
        a = w(nf+1:end, 1);
        % Store prediction for forward-looking transition variables.
        s.f0(:, 1, t) = w(1:nf, 1);
    end

    
    
    function condition( )
        % Condition time t predictions upon time t outcomes of conditioning
        % measurement variables.
        Zc = s.Z(cy, :);
        y0c = Zc*a;
        if ~isempty(d)
            y0c = y0c + d(cy, td);
        end
        pec = y1(cy, t) - y0c;
        Fc = Zc*P*Zc.' + Sy(cy, cy);
        Kc = (Zc*P).' / Fc;
        ac = a + Kc*pec;
        Pc = P - Kc*Zc*P;
        Pc = (Pc + Pc')/2;
        % Index of available non-conditioning observations.
        xy = jy & ~cy;
        if any(xy)
            Zx = s.Z(xy, :);
            y0x = Zx*ac;
            if ~isempty(d)
                y0x = y0x + d(xy, td);
            end
            pex = y1(xy, t) - y0x;
            Fx = Zx*Pc*Zx.' + Sy(xy, xy);
            if isEst
                ZZ = Zx - Zx*Kc*Zc;
                M1x = ZZ*Q1 + X(xy, :, t);
                M2x = ZZ*Q2;
                Mx = [M1x, M2x];
            end
        else
            pex = zeros(0, 1);
            Fx = zeros(0);
            if isEst
                Mx = zeros(0, nPOut+nInit);
            end
        end
    end%
end%
