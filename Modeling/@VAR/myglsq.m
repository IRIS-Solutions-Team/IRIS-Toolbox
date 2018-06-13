function S = myglsq(S, opt)
% myglsq  Generalised least squares estimator for reduced-form VARs
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

y0 = S.y0; 
k0 = S.k0; 
x0 = S.x0; 
y1 = S.y1; 
g1 = S.g1; % Lagged level variables entering the co-integrating vector.
Rr = S.Rr; 
w = S.w; 
priorDummies = opt.PriorDummies;

%--------------------------------------------------------------------------

ny = size(y0, 1); 
nk = size(k0, 1); 
nx = size(x0, 1); 
ng = size(g1, 1); 
isPrior = isa(priorDummies, 'BVAR.bvarobj') && ~isempty(priorDummies); 

% Number of lags included in regression; needs to be decreased by one for
% difference VARs or VECs.
p = opt.Order; 
if opt.Diff
    p = p - 1; 
end

% BVAR prior dummies.
numDummies = 0; 
if isPrior
    bvarY0 = priorDummies.y0(ny, p, ng, nk); 
    bvarK0 = priorDummies.k0(ny, p, ng, nk); 
    bvarY1 = priorDummies.y1(ny, p, ng, nk); 
    bvarG1 = priorDummies.g1(ny, p, ng, nk); 
    numDummies = size(bvarY0, 2); 
    bvarX0 = zeros(nx, numDummies); 
end

% Find effective estimation range and exclude NaNs.
fitted = all(~isnan([y0; k0; x0; y1; g1; w]), 1); 
nFitted = sum(double(fitted)); 
y0 = y0(:, fitted); 
k0 = k0(:, fitted); 
x0 = x0(:, fitted); 
y1 = y1(:, fitted); 
g1 = g1(:, fitted); 

if ~isempty(opt.Mean)
    yMean = opt.Mean; 
    y0 = y0 - yMean(:, ones(1, nFitted)); 
    y1 = y1 - repmat(yMean(:, ones(1, nFitted)), p, 1); 
end

% RHS observation matrix.
X = [k0; x0; y1; g1]; 

% Weighted observations.
if ~isempty(w)
    w = w(:, fitted); 
    w = w/sum(w) * nFitted; 
    sqrtw = sqrt(w); 
    y0w = y0 .* sqrtw(ones(1, ny), :); 
    k0w = k0 .* sqrtw(ones(1, nk), :); 
    x0w = x0 .* sqrtw(ones(1, nx), :); 
    Xw = X .* sqrtw(ones(nk+nx+ny*p+ng, 1), :); 
else
    y0w = y0; 
    k0w = k0; 
    x0w = x0; 
    Xw = X; 
end

if opt.Standardize && isPrior
    % Create a matrix of observations (that will be possibly demeaned)
    % including pre-sample initial condition.
    yd = y0w; 
    if nk > 0 || nx > 0
        % Demean the observations using a simple regression if the constant and/or
        % exogenous inputs ar included in the model.
        m = yd / [k0w; x0w]; 
        yd = yd - m*[k0w; x0w]; 
    end
    % Calculate the std dev on the demeaned observations, and adjust the
    % prior dummy observations. This is equivalent to standardizing the
    % observations with given dummies.
    ystd = std(yd, 1, 2); 
    bvarY0 = bvarY0 .* ystd(:, ones(1, numDummies)); 
    bvarY1 = bvarY1 .* repmat(ystd(:, ones(1, numDummies)), p, 1); 
end

% Add prior dummy observations to the LHS and RHS data matrices.
if isPrior
    y0 = [bvarY0, y0]; 
    y0w = [bvarY0, y0w]; 
    bvarX = [bvarK0; bvarX0; bvarY1; bvarG1]; 
    X = [bvarX, X]; 
    Xw = [bvarX, Xw]; 
end

if ~isempty(Rr)
    R = Rr(:, 1:end-1); 
    r = Rr(:, end); 
else
    R = [ ]; 
    r = [ ]; 
end

% `Omg0` is covariance of residuals based on unrestricted non-bayesian VAR.
% It is used to compute covariance of parameters.
Omg0 = [ ]; 
count = 0; 
if ~isempty(R) && opt.EqtnByEqtn
    % Estimate equation by equation with parameter restrictions. This procedure
    % is only valid if there are no cross-equation restrictiions. No check for
    % cross-equation restrictions is though performed; this is all the user's
    % responsibility.
    pos = (1:ny).'; 
    pos = pos(:, ones(1, nk+nx+ny*p+ng)); 
    pos = pos(:); 
    Mw = Xw * Xw.'; 
    beta = nan(ny*(nk+nx+ny*p+ng), 1); 
    realSmall = getrealsmall( ); 
    for i = 1 : ny
        % Get restrictions for equation i.
        betaInx = pos == i; 
        iR = R(betaInx, :); 
        gammaindex = any(abs(iR) > realSmall, 1); 
        iR = iR(:, gammaindex); 
        ir = r(betaInx); 
        % Estimate free hyperparameters.
        c = y0w(i, :).' - Xw.'*ir; 
        iGamma = (iR.'*Mw*iR) \ (iR.'*Xw*c); 
        beta(betaInx) = iR*iGamma + ir; 
    end
    beta = reshape(beta, [ny, ny*p+nk+nx+ng]); 
    ew = y0w - beta*Xw; 
    ew = ew(:, numDummies+1:end); 
    Omg = ew * ew.' / nFitted; 
    count = count + 1; 
else
    % Test for empty(r) not empty(R). This is because if all parameters are
    % fixed to a number, R is empty but we still need to run LSQ with
    % restrictions.
    if isempty(r)
        % Ordinary least squares for unrestricted VAR or BVAR.
        beta = y0w / Xw; 
        ew = y0w - beta*Xw; 
        ew = ew(:, numDummies+1:end); 
        Omg = ew * ew.' / nFitted; 
        Omg0 = Omg; 
        count = count + 1; 
    else
        % Generalized least squares for parameter restrictions.
        Omg = eye(ny); 
        OmgInv = eye(ny); 
        beta = Inf; 
        Mw = Xw * Xw.'; 
        maxDiff = Inf; 
        while maxDiff>opt.Tolerance && count<=opt.MaxIter
            lastBeta = beta; 
            c = y0w(:) - kron(Xw.', eye(ny))*r; 
            % Estimate free hyperparameters.
            gamma = (R.'*kron(Mw, OmgInv)*R) \ (R.'*kron(Xw, OmgInv)*c); 
            % Compute parameters.
            beta = reshape(R*gamma + r, [ny, ny*p+nk+nx+ng]); 
            ew = y0w - beta*Xw; 
            ew = ew(:, numDummies+1:end); 
            Omg = ew * ew.' / nFitted; 
            OmgInv = inv(Omg); 
            maxDiff = max(abs(beta(:) - lastBeta(:))); 
            count = count + 1; 
        end
    end
end

% Unweighted residuals.
e = y0 - beta*X; 
e = e(:, numDummies+1:end); 

% Covariance of parameter estimates, not available for VECM and diff VARs.
Sgm = [ ]; 
if opt.CovParameters && ~opt.Diff
    covParameters( ); 
end

% Coefficients of exogenous inputs including constant.
K = beta(:, 1:nk); 
beta(:, 1:nk) = [ ]; 

J = beta(:, 1:nx); 
beta(:, 1:nx) = [ ]; 

% Transition matrices.
A = beta(:, 1:ny*p); 
beta(:, 1:ny*p) = [ ]; 

% Coefficients of the co-integrating vector.
G = beta(:, 1:ng); 
beta(:, 1:ng) = [ ]; %#ok<NASGU>

S.A = A; 
S.K = K; 
S.J = J; 
S.G = G; 
S.Omg = Omg; 
S.Sgm = Sgm; 
S.resid = nan(size(S.y0)); 
S.resid(:, fitted) = e; 
S.count = count; 

return


    function covParameters( )
        % Asymptotic covariance of parameters is based on the covariance matrix of
        % residuals from a non-restricted non-bayesian VAR. The risk exists that we
        % bump into singularity or near-singularity.
        if isempty(Omg0)
            if ~isempty(Xw)
                beta0 = y0w / Xw; 
                e0w = y0w - beta0*Xw; 
                e0w = e0w(:, numDummies+1:end); 
                Omg0 = e0w * e0w.' / nFitted; 
            else
                Omg0 = nan(ny); 
            end
        end
        if isempty(r)
            % Unrestricted parameters, `Mw` may not be available.
            if ~isempty(Xw)
                Mw = Xw * Xw.'; 
                Sgm = kron(inv(Mw), Omg0); 
            else
                Sgm = nan(size(Xw, 1)*ny); 
            end
        elseif ~isempty(R)
            % If `R` is empty, all parameters are fixed, and we do not have to
            % calculate `Sgm`. If not, then `Mx` and `OmgInv` are guaranteed
            % to exist.
            if ~isempty(Xw)
                Sgm = R*((R.'*kron(Mw, inv(Omg0))*R) \ R.'); 
            else
                Sgm = nan(size(Xw, 1)*ny); 
            end
        end
    end 
end
