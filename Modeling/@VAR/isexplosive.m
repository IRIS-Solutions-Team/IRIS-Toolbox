function Flag = isexplosive(This,varargin)
% isexplosive  True if any eigenvalue is outside unit circle.
%
% Syntax
% =======
%
%     Flag = isexplosive(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object whose eigenvalues will be tested for
% explosiveness.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if at least one eigenvalue is
% outside unit circle.
%
% Options
% ========
%
% * `'tolerance='` [ numeric | *`getrealsmall( )`* ] - Tolerance for the
% eigenvalue test.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

opt = passvalopt('VAR.isexplosive',varargin{:});

%--------------------------------------------------------------------------

Flag = any(abs(This.EigVal) > 1+opt.tolerance,2);
Flag = Flag(:)';

end
