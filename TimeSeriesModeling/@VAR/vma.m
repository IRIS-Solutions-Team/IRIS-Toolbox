function Phi = vma(this, N)
% vma  Matrices describing the VMA representation of a VAR process.
%
% Syntax
% =======
%
%     Phi = vma(V, N)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object for which the VMA matrices will be computed.
%
% * `N` [ numeric ] - Order up to which the VMA matrices will be computed.
%
% Output arguments
% =================
%
% * `Phi` [ numeric ] - VMA matrices.
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
pp = inputParser( );
pp.addRequired('N', isnumericscalar);
pp.parse(N);

[A, B] = getIthSystemk(this);
Phi = timedom.var2vma(A, B, N);

end%

