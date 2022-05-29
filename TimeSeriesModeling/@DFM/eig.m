function e = eig(a)
% eig  Eigenvalues of DFM model.
%
% Syntax
% =======
%
%     E = eig(A)
%
% Input arguments
% ================
%
% * `A` [ DFM ] - DFM object.
%
% Output arguments
% =================
%
% * `E` [ numeric ] - Eigenvalues associated with the dynamic system of the
% DFM model.
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

e = a.EigVal;

end
