function s = generalizedLsq(s, opt)
% generalizedLsq  Generalised least squares estimator for reduced-form VARs
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

y0 = s.y0; % LHS data
k0 = s.k0; % Constant and dummies
x0 = s.x0; % Exogenous variables
y1 = s.y1; % Own lags
g1 = s.g1; % Lagged level variables entering the co-integrating vector
Rr = s.Rr; % Linear restrictions on parameters: beta = R*gamma + r
w = s.w;   % Variance-based weights
priorDummies = opt.PriorDummies;

%--------------------------------------------------------------------------

numY = size(y0, 1); 
numK = size(k0, 1); 
numX = size(x0, 1); 
numG = size(g1, 1); 
isPrior = isa(priorDummies, 'BVAR.DummyWrapper') && ~isempty(priorDummies); 

if ~isempty(Rr)
    R = Rr(:, 1:end-1); 
    r = Rr(:, end); 
else
    R = [ ]; 
    r = [ ]; 
end

% Number of lags included in regression; needs to be decreased by one for
% difference VARs or VECs
p = opt.Order; 
numOwnLags = p;
if opt.Diff
    p = p - 1; 
end

% BVAR prior dummies
numPriors = 0; 
if isPrior
    bvarY0 = priorDummies.y0(numY, p, numG, numK); 
    bvarK0 = priorDummies.k0(numY, p, numG, numK); 
    bvarY1 = priorDummies.y1(numY, p, numG, numK); 
    bvarG1 = priorDummies.g1(numY, p, numG, numK); 
    numPriors = size(bvarY0, 2); 
    bvarX0 = zeros(numX, numPriors); 
end

% Find effective estimation range and exclude NaNs
inxFitted = all(~isnan([y0; k0; x0; y1; g1; w]), 1); 
numFitted = nnz(inxFitted);
y0 = y0(:, inxFitted); 
k0 = k0(:, inxFitted); 
x0 = x0(:, inxFitted); 
y1 = y1(:, inxFitted); 
g1 = g1(:, inxFitted); 

if ~isempty(opt.Mean)
    yMean = opt.Mean; 
    y0 = bsxfun(@minus, y0, yMean);
    y1 = bsxfun(@minus, y1, repmat(yMean, numOwnLags, 1));
end

% RHS observation matrix
X = [k0; x0; y1; g1]; 
if isempty(R)
    degreesFreedom = size(X, 1);
else
    degreesFreedom = size(R, 2) / numY;
end

% Number of periods fitted with a small sample correction
numFittedCorrected = numFitted;
if opt.SmallSampleCorrection
    numFittedCorrected = numFittedCorrected - degreesFreedom;
end

% Weighted observations
if ~isempty(w)
    w = w(:, inxFitted); 
    w = w/sum(w) * numFittedCorrected; 
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
    % including pre-sample initial condition
    yd = y0w; 
    if numK > 0 || numX > 0
        % Demean the observations using a simple regression if the constant and/or
        % exogenous inputs ar included in the model
        m = yd / [k0w; x0w]; 
        yd = yd - m*[k0w; x0w]; 
    end
    % Calculate the std dev on the demeaned observations, and adjust the
    % prior dummy observations. This is equivalent to standardizing the
    % observations with given dummies
    ystd = std(yd, 1, 2); 
    bvarY0 = bvarY0 .* ystd(:, ones(1, numPriors)); 
    bvarY1 = bvarY1 .* repmat(ystd(:, ones(1, numPriors)), p, 1); 
end

% Add prior dummy observations to the LHS and RHS data matrices
if isPrior
    y0 = [bvarY0, y0]; 
    y0w = [bvarY0, y0w]; 
    bvarX = [bvarK0; bvarX0; bvarY1; bvarG1]; 
    X = [bvarX, X]; 
    Xw = [bvarX, Xw]; 
end

% `Omg0` is covariance of residuals based on unrestricted non-bayesian VAR;
% this matrix is used to compute the covariance matrix of parameters
Omg0 = [ ]; 

numLhs = size(y0w, 1);
numRhs = size(Xw, 1);
iter = 0; 
if ~isempty(R) && opt.EqtnByEqtn
    % Estimate equation by equation with parameter restrictions; this
    % procedure is only valid if there are no cross-equation restrictiions;
    % no check for cross-equation restrictions is performed (this is the
    % user's responsibility)
    pos = transpose(1:numLhs); 
    pos = repmat(pos, 1, numRhs);
    pos = pos(:); 
    Mw = Xw * transpose(Xw);
    beta = nan(numLhs*numRhs, 1); 
    for i = 1 : numLhs
        % Get restrictions for the ith equation
        inxBeta = pos==i; 
        R__ = R(inxBeta, :); 
        inxGamma = any(abs(R__)>opt.Tolerance, 1); 
        R__ = R__(:, inxGamma); 
        ir = r(inxBeta); 
        % Estimate free hyperparameters
        c = transpose(y0w(i, :)) - transpose(Xw)*ir; 
        gamma_ = ( transpose(R__)*Mw*R__ ) \ ( transpose(R__)*Xw*c ); 
        beta(inxBeta) = R__*gamma_ + ir; 
    end
    beta = reshape(beta, [numLhs, numRhs]); 
    ew = y0w - beta*Xw; 
    ew = ew(:, numPriors+1:end); 
    Omg = ew * transpose(ew) / numFittedCorrected; 
    iter = iter + 1; 
else
    % Test for empty(r) not empty(R). This is because if all parameters are
    % fixed to a number, R is empty but we still need to run LSQ with
    % restrictions
    if isempty(r)
        % Ordinary least squares for unrestricted VAR or BVAR
        beta = y0w / Xw; 
        ew = y0w - beta*Xw; 
        ew = ew(:, numPriors+1:end); 
        Omg = ew * transpose(ew) / numFittedCorrected; 
        Omg0 = Omg; 
        iter = iter + 1; 
    else
        % Generalized least squares for parameter restrictions
        Omg = eye(numY); 
        invOmg = eye(numY); 
        beta = Inf; 
        Mw = Xw * transpose(Xw);
        maxDiff = Inf; 
        while maxDiff>opt.Tolerance && iter<=opt.MaxIter
            lastBeta = beta; 
            c = y0w(:) - kron( transpose(Xw), eye(numY) )*r; 
            % Estimate free hyperparameters.
            gamma = ( transpose(R)*kron(Mw, invOmg)*R ) \ ( transpose(R)*kron(Xw, invOmg)*c ); 
            % Compute parameters.
            beta = reshape(R*gamma + r, numLhs, numRhs); 
            ew = y0w - beta*Xw; 
            ew = ew(:, numPriors+1:end); 
            Omg = ew * transpose(ew) / numFittedCorrected; 
            invOmg = inv(Omg); 
            maxDiff = max(abs(beta(:) - lastBeta(:))); 
            iter = iter + 1; 
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
K = beta(:, 1:numK); 
beta(:, 1:numK) = [ ]; 

J = beta(:, 1:numX); 
beta(:, 1:numX) = [ ]; 

% Transition matrices
A = beta(:, 1:numY*p); 
beta(:, 1:numY*p) = [ ]; 

% Coefficients of the co-integrating vector.
G = beta(:, 1:numG); 
beta(:, 1:numG) = [ ]; %#ok<NASGU>

s.A = A; 
s.K = K; 
s.J = J; 
s.G = G; 
s.Omg = Omg; 
s.Sgm = Sgm; 
s.resid = nan(size(s.y0)); 
s.resid(:, inxFitted) = e; 
s.count = iter; 
s.InxFitted = inxFitted;

return


    function hereCovParameters( )
        % Asymptotic covariance of parameters is based on the covariance matrix of
        % residuals from a non-restricted non-bayesian VAR; the risk exists that we
        % run into singularity or near-singularity
        if isempty(Omg0)
            if ~isempty(Xw)
                beta0 = y0w / Xw; 
                e0w = y0w - beta0*Xw; 
                e0w = e0w(:, numPriors+1:end); 
                Omg0 = e0w * transpose(e0w) / numFittedCorrected; 
            else
                Omg0 = nan(numY); 
            end
        end
        if isempty(r)
            % Unrestricted parameters, `Mw` may not be available
            if ~isempty(Xw)
                Mw = Xw * transpose(Xw); 
                Sgm = kron(inv(Mw), Omg0); 
            else
                Sgm = nan(numRhs*numY); 
            end
        elseif ~isempty(R)
            % If `R` is empty, all parameters are fixed, and we do not have to
            % calculate `Sgm`; if not, then `Mx` and `invOmg` are guaranteed
            % to exist
            if ~isempty(Xw)
                Rt = transpose(R);
                invOmg0 = inv(Omg0);
                Sgm = R*( (Rt*kron(Mw, invOmg0)*R) \ Rt); 
            else
                Sgm = nan(size(Xw, 1)*numY); 
            end
        end
    end%
end%

