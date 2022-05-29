function [X, C, E, Sgm, Sing, Sample, CTF] = pc(Y, Crit, Method)
% pc  Principal components of input series
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

% crit = [power, maxnumber].
if length(Crit) == 1
    Crit = [Crit, Inf];
end

[ny, nPer] = size(Y);

if strcmpi(Method, 'auto')
    if nPer > ny
        Method = 1;
    else
        Method = 2;
    end
end

% Non-NaN sample.
nanInx = isnan(Y);
Sample = all(~nanInx, 1);
nObs = sum(Sample);
if nObs == 2
    utils.error('DFM:pc', 'No observations available to estimate DFM.');
end

% Covariance matrix of input series.
% The matrix is needed whatever method.
yCov = Y(:, Sample)*Y(:, Sample)'/nObs;
if any(isinf(yCov(:)) | isnan(yCov(:)))
    utils.error('DFM:pc', 'Sample covariance matrix contains NaNs or Infs.');
end

if Method == 1
    Q = yCov;
    n = ny;
else
    Q = Y(:, Sample)'*Y(:, Sample)/nObs;
    n = nObs;
end

[U, Sing] = svd(Q);
Sing = diag(Sing(1:n, 1:n));
cumSing = cumsum(Sing);
cumSing = cumSing/cumSing(end);
r = min([find(cumSing >= Crit(1), 1), Crit(2)]);
X = nan(r, nPer);
E = nan(ny, nPer);
CTF = nan(ny, nPer, r);

% y = C*x + e;
if Method == 1
    C = U(:, 1:r);
    X(:, Sample) = C.'*Y(:, Sample);
    
    % Normalise stdevs of the factors to 1.
    a = sqrt(Sing(1:r));
    C = C*diag(a);
    X(:, Sample) = diag(1./a)*X(:, Sample);
    
else
    X(:, Sample) = U(:, 1:r).';
    C = Y(:, Sample)*X(:, Sample).';
    
    % Normalise stdevs of the factors to 1.
    C = C/sqrt(nObs);
    X = sqrt(nObs)*X;
end

% Contributions of input data to the estimated factors.
repeat = ones(1, nObs);
for i = 1 : r
    Ci = C(:, i*repeat);
    CTF(:, Sample, i) = Ci.*Y(:, Sample) / Sing(i);
end

% The number of factors equals the number of input series.
if r == ny
    E(:, Sample) = 0;
    Sgm = zeros(ny);
else
    E(:, Sample) = Y(:, Sample) - C*X(:, Sample);
    Sgm = yCov - C*C';
end

end
