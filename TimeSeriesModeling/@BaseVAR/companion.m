function [A, B, K, J, Cov] = companion(this, varargin)
% companion  Matrices of first-order companion VAR
%
% Syntax
% =======
%
%     [A, B, K, J, Cov] = companion(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object for which the companion matrices will be
% returned.
%
% Output arguments
% =================
%
% * `A` [ numeric ] - First-order companion transition matrix.
%
% * `B` [ numeric ] - First-order companion coefficient matrix in front of
% reduced-form residuals.
%
% * `K` [ numeric ] - First-order compnaion constant vector.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = this.NumEndogenous;
p = this.Order;
nv = countVariants(this);

if p==0
    A = zeros(ny, ny, nv);
else
    A = zeros(ny*p, ny*p, nv);
    for i = 1 : nv
        A(:, :, i) = [this.A(:, :, i);eye(ny*(p-1), ny*p)];
    end
end

if nargout>1
    [Cov, B] = getResidualComponents(this);
    B = [B;zeros(ny*(p-1), ny, nv)];
end

if nargout>2
    K = this.K;
    K(end+(1:ny*(p-1)), :, :) = 0;
end

if nargout>3
    J = this.J;
    J(end+(1:ny*(p-1)), :, :) = 0;
end

end%

