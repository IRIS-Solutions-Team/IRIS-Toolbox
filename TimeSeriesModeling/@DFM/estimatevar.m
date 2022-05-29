function [A, B, Omg, u, fitted] = estimatevar(X, P, Q)
% estimatevar  Estimate VAR(p, q) on factors.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

nx = size(X, 1);
nPer = size(X, 2);

% Stack vectors of x(t), x(t-1), etc.
t = P+1 : nPer;
presample = nan(nx, P);
x0 = [presample, X(:, t)];
x1 = [ ];
for i = 1 : P
   x1 = [x1;presample, X(:, t-i)]; %#ok<AGROW>
end

% Determine dates with no missing observations.
fitted = all(~isnan([x0;x1]));
nObs = sum(fitted);

% Estimate VAR and reduced-form residuals.
A = x0(:, fitted)/x1(:, fitted);
e = x0 - A*x1;
Omg = e(:, fitted)*e(:, fitted)'/nObs;

% Number of orthonormalised shocks driving the factor VAR.
if Q > nx
   Q = nx;
end

% Compute principal components of reduced-form residuals, back out
% orthonormalised residuals.
% e = B u, 
% Euu' = I.
[B, u] = covfun.orthonorm(Omg, Q, 1, e);
B = B(:, 1:Q, :);
u = u(1:Q, :, :);

end
