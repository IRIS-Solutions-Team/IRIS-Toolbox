function this = isactive(this, type, varargin)
% isactive  True if dynamic link or steady-state revision is active (not disabled).
%
%
% Syntax
% =======
%
%     d = isactive(m, '!links')
%     flag = isactive(m, '!links', name);
%     d = isactive(m, '!revisions');
%     flag = isactive(m, '!revisions', name);
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object.
%
% * `name` [ char ] - Name of LHS variable in links or steady-state
% revision equations whose status will be returned.
%
%
% Output arguments
% =================
%
% * `d` [ cellstr ] - Database with the status (`true` means active,
% `false` means inactive) for each LHS name in [`!links`](irislang/links)
% or [`!revisions`](irislang/revisions) equations.
%
% * `flag` [ `true` | `false` ] - Returns `true` for active
% [`!links`](irislang/links) or [`!revisions`](irislang/revisions),
% `false` for inactive (disabled).
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

this = operateLock(this, type, 0, varargin{:});

end
