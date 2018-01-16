function this = enable(this, type, varargin)
% enable  Enable dynamic links or revision equations.
%
% Syntax
% =======
%
%     M = enable(M, '!links')
%     M = enable(M, '!links', Name1, Name2, ...);
%     M = enable(M, '!revisions');
%     M = enable(M, '!revisions', Name1, Name2,...);
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Name1`, `Name2`, ... [ char ] - Names whose links or steady-state
% revision equations will be enabled.
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with dynamic links
% [`!links`](modellang/links) or steady-state revision equations
% [`!revisions`](modellang/revisions) enabled.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

this = operateLock(this, type, 1, varargin{:});

end
