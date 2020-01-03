function S = myglsq(S, opt)
% myglsq  Generalised least squares estimator for reduced-form VARs
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

y0 = S.y0; % LHS data
k0 = S.k0; % Constant and dummies
x0 = S.x0; % Exogenous variables
y1 = S.y1; % Own lags
g1 = S.g1; % Lagged level variables entering the co-integrating vector
Rr = S.Rr; % Linear restrictions on parameters: beta = R*gamma + r
w = S.w;   % Variance-based weights
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
numOwnLags = p;
if opt.Diff
    p = p - 1; 
end

% BVAR prior dummies.
numPriors = 0; 
if isPrior
    bvarY0 = priorDummies.y0(ny, p, ng, nk); 
    bvarK0 = priorDummies.k0(ny, p, ng, nk); 
    bvarY1 = priorDummies.y1(ny, p, ng, nk); 
    bvarG1 = priorDummies.g1(ny, p, ng, nk); 
    numPriors = size(bvarY0, 2); 
    bvarX0 = zeros(nx, numPriors); 
end

% Find effective estimation range and exclude NaNs.
fitted = all(~isnan([y0; k0; x0; y1; g1; w]), 1); 
numFitted = sum(double(fitted)); 
y0 = y0(:, fitted); 
k0 = k0(:, fitted); 
x0 = x0(:, fitted); 
y1 = y1(:, fitted); 
g1 = g1(:, fitted); 

if ~isempty(opt.Mean)
    yMean = opt.Mean; 
    y0 = bsxfun(@minus, y0, yMean);
    y1 = bsxfun(@minus, y1, repmat(yMean, numOwnLags, 1));
end

% RHS observation matrix.
X = [k0; x0; y1; g1]; 

% Weighted observations
if ~isempty(w)
    w = w(:, fitted); 
    w = w/sum(w) * numFitted; 
    sqrtw = sqrt(w); 
    y0w = bsxfun(@times, y0, sqrtw);
    k0w = bsxfun(@times, k0, sqrtw);
    x0w = bsxfun(@times, x0, sqrtw);
    Xw  = bsxfun(@times, X,  sqrtw);
else
    y0w = y0; 
    k0w = k0; 
    x0w = x0; 
    Xw  = X; 
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
    bvarY0 = bvarY0 .* ystd(:, ones(1, numPriors)); 
    bvarY1 = bvarY1 .* repmat(ystd(:, ones(1, numPriors)), p, 1); 
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

numLhs = size(y0w, 1);
numRhs = size(Xw, 1);
count = 0; 
if ~isempty(R) && opt.EqtnByEqtn
    % Estimate equation by equation with parameter restrictions. This procedure
    % is only valid if there are no cross-equation restrictiions. No check for
    % cross-equation restrictions is though performed; this is all the user's
    % responsibility.
    pos = transpose(1:numLhs); 
    pos = repmat(pos, 1, numRhs);
    pos = pos(:); 
    Mw = Xw * transpose(Xw);
    beta = nan(numLhs*numRhs, 1); 
    realSmall = getrealsmall( ); 
    for i = 1 : numLhs
        % Get restrictions for equation i
        inxBeta = pos==i; 
        iR = R(inxBeta, :); 
        inxGamma = any(abs(iR)>realSmall, 1); 
        iR = iR(:, inxGamma); 
        ir = r(inxBeta); 
        % Estimate free hyperparameters
        c = transpose(y0w(i, :)) - transpose(Xw)*ir; 
        iGamma = ( transpose(iR)*Mw*iR ) \ ( transpose(iR)*Xw*c ); 
        beta(inxBeta) = iR*iGamma + ir; 
    end
    beta = reshape(beta, [numLhs, numRhs]); 
    ew = y0w - beta*Xw; 
    ew = ew(:, numPriors+1:end); 
    Omg = ew * transpose(ew) / numFitted; 
    count = count + 1; 
else
    % Test for empty(r) not empty(R). This is because if all parameters are
    % fixed to a number, R is empty but we still need to run LSQ with
    % restrictions.
    if isempty(r)
        % Ordinary least squares for unrestricted VAR or BVAR.
        beta = y0w / Xw; 
        ew = y0w - beta*Xw; 
        ew = ew(:, numPriors+1:end); 
        Omg = ew * transpose(ew) / numFitted; 
        Omg0 = Omg; 
        count = count + 1; 
    else
        % Generalized least squares for parameter restrictions.
        Omg = eye(ny); 
        invOmg = eye(ny); 
        beta = Inf; 
        Mw = Xw * transpose(Xw);
        maxDiff = Inf; 
        while maxDiff>opt.Tolerance && count<=opt.MaxIter
            lastBeta = beta; 
            c = y0w(:) - kron( transpose(Xw), eye(ny) )*r; 
            % Estimate free hyperparameters.
            gamma = ( transpose(R)*kron(Mw, invOmg)*R ) \ ( transpose(R)*kron(Xw, invOmg)*c ); 
            % Compute parameters.
            beta = reshape(R*gamma + r, numLhs, numRhs); 
            ew = y0w - beta*Xw; 
            ew = ew(:, numPriors+1:end); 
            Omg = ew * transpose(ew) / numFitted; 
            invOmg = inv(Omg); 
            maxDiff = max(abs(beta(:) - lastBeta(:))); 
            count = count + 1; 
        end
    end
end

% Unweighted residuals
e = y0 - beta*X; 
e = e(:, numPriors+1:end); 

% Covariance of parameter estimates, not available for VECM and diff VARs.
Sgm = [ ]; 
if opt.CovParameters && ~opt.Diff
    hereCovParameters( ); 
end

% Coefficients of exogenous inputs including constant
K = beta(:, 1:nk); 
beta(:, 1:nk) = [ ]; 

J = beta(:, 1:nx); 
beta(:, 1:nx) = [ ]; 

% Transition matrices
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


    function hereCovParameters( )
        % Asymptotic covariance of parameters is based on the covariance matrix of
        % residuals from a non-restricted non-bayesian VAR. The risk exists that we
        % bump into singularity or near-singularity.
        if isempty(Omg0)
            if ~isempty(Xw)
                beta0 = y0w / Xw; 
                e0w = y0w - beta0*Xw; 
                e0w = e0w(:, numPriors+1:end); 
                Omg0 = e0w * transpose(e0w) / numFitted; 
            else
                Omg0 = nan(ny); 
            end
        end
        if isempty(r)
            % Unrestricted parameters, `Mw` may not be available.
            if ~isempty(Xw)
                Mw = Xw * transpose(Xw); 
                Sgm = kron(inv(Mw), Omg0); 
            else
                Sgm = nan(numRhs*ny); 
            end
        elseif ~isempty(R)
            % If `R` is empty, all parameters are fixed, and we do not have to
            % calculate `Sgm`. If not, then `Mx` and `invOmg` are guaranteed
            % to exist.
            if ~isempty(Xw)
                Rt = transpose(R);
                invOmg0 = inv(Omg0);
                Sgm = R*( (Rt*kron(Mw, invOmg0)*R) \ Rt); 
            else
                Sgm = nan(size(Xw, 1)*ny); 
            end
        end
    end%
end%

