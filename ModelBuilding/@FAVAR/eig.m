function e = eig(a)
% eig  Eigenvalues of FAVAR model.
%
% Syntax
% =======
%
%     E = eig(A)
%
% Input arguments
% ================
%
% * `A` [ FAVAR ] - FAVAR object.
%
% Output arguments
% =================
%
% * `E` [ numeric ] - Eigenvalues associated with the dynamic system of the
% FAVAR model.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

e = a.EigVal;

end