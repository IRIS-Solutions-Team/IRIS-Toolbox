function this = disable(this, type, varargin)
% disable  Disable dynamic links or steady-state revision equations.
%
% Syntax
% =======
%
%     M = disable(M, '!links')
%     M = disable(M, '!links', Name1, Name2, ...);
%     M = disable(M, '!revisions');
%     M = disable(M, '!revisions', Name1, Name2, ...);
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Name1`, `Name2`, ... [ char ] - Names whose links or revision equations
% will be temporarily disabled.
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with dynamic links
% [`!links`](modellang/links) or steady-state revision equations
% [`!revisions`](modellang/revisions) temporarily disabled, until
% [`unlock`](model/unlock).
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

this = operateLock(this, type, -1, varargin{:});

end
