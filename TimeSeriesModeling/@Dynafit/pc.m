% pc  Principal components of input series
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [X, C, E, Sigma, singValues, inxSample, ctf] = pc(Y, crit, method)

% crit = [power, maxnumber]
if numel(crit)==1
    crit = [crit, Inf];
end

[ny, nPer] = size(Y);

if strcmpi(method, 'auto')
    if nPer>ny
        method = 1;
    else
        method = 2;
    end
end

% Non-NaN sample.
nanInx = isnan(Y);
inxSample = all(~nanInx, 1);
nObs = sum(inxSample);
if nObs==2
    utils.error('Dynafit', 'No observations available to estimate Dynafit object.');
end

% Covariance matrix of input series.
% The matrix is needed whatever method.
covY = Y(:, inxSample)*Y(:, inxSample)'/nObs;
if any(~isfinite(covY(:)))
    utils.error('Dynafit', 'Sample covariance matrix contains NaNs or Infs.');
end

if method==1
    Q = covY;
    n = ny;
else
    Q = Y(:, inxSample)'*Y(:, inxSample)/nObs;
    n = nObs;
end

[U, singValues] = svd(Q);
singValues = diag(singValues(1:n, 1:n));
cumSing = cumsum(singValues);
cumSing = cumSing/cumSing(end);
r = min([find(cumSing>=crit(1), 1), crit(2)]);
X = nan(r, nPer);
E = nan(ny, nPer);
ctf = nan(ny, nPer, r);

% y = C*x + e;
if method==1
    C = U(:, 1:r);
    X(:, inxSample) = C.'*Y(:, inxSample);
    
    % Normalise stdevs of the factors to 1.
    a = sqrt(singValues(1:r));
    C = C*diag(a);
    X(:, inxSample) = diag(1./a)*X(:, inxSample);
    
else
    X(:, inxSample) = U(:, 1:r).';
    C = Y(:, inxSample)*X(:, inxSample).';
    
    % Normalise stdevs of the factors to 1.
    C = C/sqrt(nObs);
    X = sqrt(nObs)*X;
end

% Contributions of input data to the estimated factors.
repeat = ones(1, nObs);
for i = 1 : r
    Ci = C(:, i*repeat);
    ctf(:, inxSample, i) = Ci.*Y(:, inxSample) / singValues(i);
end

if r==ny
    % Special case: the number of factors equals the number of input series
    E(:, inxSample) = 0;
    Sigma = zeros(ny);
else
    E(:, inxSample) = Y(:, inxSample) - C*X(:, inxSample);
    Sigma = covY - C*C';
end

end%

