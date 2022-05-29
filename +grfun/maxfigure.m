function Fig = maxfigure(varargin)
% maxfigure  Maximize figure window.
%
% Syntax
% =======
%
%     Fig = maxfigure(H,...)
%     Fig = maxfigure(...)
%
% Input arguments
% ================
%
% * `H` [ handle ] - Handle to existing figure window that will be
% maximized; if omitted, a new maximized figure window will be created.
%
% Output arguments
% =================
%
% * `Fig` [ numeric ] - Handle to the figure created.
%
% Options
% ========
%
% See help on standar `figure` for the options available.
%
% Description
% ============
%
% The function `maxfigure` uses `get(0,'screenSize')` to determine the size
% of the screen, and sets the figure property `'outerPosition'`
% accordingly.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

screenSize = get(0,'screenSize');

if ~isempty(varargin) && all(ishandle(varargin{1}))
    Fig = varargin{1};
    varargin(1) = [ ];
    set(Fig,'outerPosition',screenSize,varargin{:});
else
    Fig = figure('outerPosition',screenSize,varargin{:});
end
    
end
