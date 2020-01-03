function this = disable(this, type, varargin)
% disable  Disable dynamic links or steady-state revision equations.
%
% ## Syntax ##
%
%     M = disable(M, '!links')
%     M = disable(M, '!links', Name1, Name2, ...);
%     M = disable(M, '!revisions');
%     M = disable(M, '!revisions', Name1, Name2, ...);
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Model object.
%
% * `Name1`, `Name2`, ... [ char ] - Names whose links or revision equations
% will be temporarily disabled.
%
%
% ## Output Arguments ##
%
% * `M` [ model ] - Model object with dynamic links
% [`!links`](irislang/links) or steady-state revision equations
% [`!revisions`](irislang/revisions) temporarily disabled until
% enabled by [`enable`](#enable) again.
%
%
% Example
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

this = operateLock(this, type, -1, varargin{:});

end
