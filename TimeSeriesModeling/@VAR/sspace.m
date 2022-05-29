function [T, R, k, Z, H, d, U, Cov] = sspace(this, varargin)
% sspace  Quasi-triangular state-space representation of VAR.
%
% Syntax
% =======
%
%     [T, R, K, Z, H, D, Cov] = sspace(V, ...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `T` [ numeric ] - Transition matrix.
%
% * `R` [ numeric ] - Matrix of instantaneous effect of residuals (forecast
% errors).
%
% * `K` [ numeric ] - Constant vector in transition equations.
%
% * `Z` [ numeric ] - Matrix mapping transition variables to measurement
% variables.
%
% * `H` [ numeric ] - Matrix at the shock vector in measurement
% equations (all zeros in VAR objects).
%
% * `D` [ numeric ] - Constant vector in measurement equations (all zeros
% in VAR objects).
%
% * `U` [ numeric ] - Transformation matrix for predetermined variables.
%
% * `Cov` [ numeric ] - Covariance matrix of residuals (forecast errors).
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if ~isempty(varargin) && validate.numericScalar(varargin{1}) 
   variantsRequested = varargin{1};
   varargin(1) = [ ]; %#ok<NASGU>
else
   variantsRequested = ':';
end

%--------------------------------------------------------------------------

ny = this.NumEndogenous;
order = this.Order;

T = this.T(:, :, variantsRequested);
n3 = size(T, 3);

U = this.U(:, :, variantsRequested);
Z = U(1:ny, :, :);
R = permute(U(1:ny, :, :), [2, 1, 3]);

% Constant term
K = this.K(:, :, variantsRequested);
k = repmat(zeros(size(K)), order, 1);
for i3 = 1 : n3
   k(:, :, i3) = transpose(U(1:ny, :, i3))*K(:, :, i3);
end

H = zeros(ny, ny, n3);
d = zeros(ny, 1, n3);

% Covariance matrix of forecast errors
Cov = this.Omega(:, :, variantsRequested);

end%

