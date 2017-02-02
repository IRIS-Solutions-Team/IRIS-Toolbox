function Flag = isstationary(This,varargin)
% isstationary  True if all eigenvalues are within unit circle.
%
% Syntax
% =======
%
%     Flag = isstationary(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object whose eigenvalues will be tested for
% stationarity.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if all eigenvalues are within unit
% circle.
%
% Options
% ========
%
% * `'tolerance='` [ numeric | *`getrealsmall( )`* ] - Tolerance for the
% eigenvalue test.
%


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

opt = passvalopt('VAR.isstationary',varargin{:});

%--------------------------------------------------------------------------

Flag = all(abs(This.EigVal) <= 1-opt.tolerance,2);
Flag = Flag(:).';

end
