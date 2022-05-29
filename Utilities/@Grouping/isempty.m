function flag = isempty(this)
% isempty  True for empty Grouping object.
%
% Syntax
% =======
%
%     flag = isempty(g)
%
%
% Input arguments
% ================
%
% * `g` [ Grouping ] - Grouping object.
%
%
% Output arguments
% =================
%
% * `flag` [ `true` | `false` ] - True if `g` is a Grouping object with no
% groups.
%
%
% Description
% ============
%
%
% Example
% ========
%
%     g = Grouping( );
%     isempty(g)
%     ans = 
%          1
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

flag = isempty(this.GroupNames);

end
