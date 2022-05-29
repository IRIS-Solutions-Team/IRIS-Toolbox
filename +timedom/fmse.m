% fmse  Forecast mean square error matrices for general state space
%
% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function X = fmse(T, R, K, Z, H, D, U, Omega, nper)

ny = size(Z, 1);
[nx, nb] = size(T);
nf = nx - nb;
n = ny + nf + nb;

% Compute VMA representation
Phi = timedom.srf(T, R, K, Z, H, D, U, Omega, nper);
Phi(:, :, 1) = [ ];

X = nan(n, n, nper);
for t = 1 : nper
   X(:, :, t) = Phi(:, :, t)*Omega*transpose(Phi(:, :, t));
end
X = cumsum(X, 3);

end%

