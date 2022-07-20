function [T, R, k, Z, H, d, U, Cov] = sspace(this, varargin)
% sspace  Quasi-triangular state-space representation of SVAR.
%
% Syntax
% =======
%
%     [T, R, K, Z, H, D, Cov] = sspace(V, ...)
%
% Input arguments
% ================
%
% * `V` [ SVAR ] - SVAR object.
%
% Output arguments
% =================
%
% * `T` [ numeric ] - Transition matrix.
%
% * `R` [ numeric ] - Matrix of instantaneous effect of structural shocks.
%
% * `K` [ numeric ] - Constant vector in transition equations.
%
% * `Z` [ numeric ] - Matrix mapping transition variables to measurement
% variables.
%
% * `H` [ numeric ] - Matrix at the shock vector in measurement
% equations (all zeros in SVAR objects).
%
% * `D` [ numeric ] - Constant vector in measurement equations (all zeros
% in SVAR objects).
%
% * `U` [ numeric ] - Transformation matrix for predetermined variables.
%
% * `Cov` [ numeric ] - Covariance matrix of structural shocks.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

isnumericscalar = @(x) isnumeric(x) && isscalar(x);
if ~isempty(varargin) && isnumericscalar(varargin{1}) 
   variantsRequested = varargin{1};
   varargin(1) = [ ]; %#ok<NASGU>
else
   variantsRequested = ':';
end

%--------------------------------------------------------------------------

[T, R, k, Z, H, d, U, ~] = sspace@VAR(this, variantsRequested);

[Cov, B] = getResidualComponents(this, variantsRequested);
for i = 1 : size(R, 3)
    R(:, :, i) = R(:, :, i)*B(:, :, i);
end

end%

