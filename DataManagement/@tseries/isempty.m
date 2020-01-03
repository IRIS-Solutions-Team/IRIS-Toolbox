function Flag = isempty(This)
% isempty  True if tseries object data matrix is empty.
%
% Syntax
% =======
%
%      Flag = isempty(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if tseries object data matrix is
% empty.
%
% Description
% ============
%
% Example
% ========
%
%     x1 = tseries(1:10,@rand);
%     isempty(x1)
%     ans =
%          0
%
%     x2 = tseries( );
%     isempty(x2)
%     ans =
%          1
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isempty(This.data);

end
