function varargout = scatter(varargin)
% scatter  Scatter graph for tseries objects.
%
% Syntax
% =======
%
%     [H, Range] = scatter([X, Y], ...)
%     [H, Range] = scatter([X, Y, Z], ...)
%     [H, Range] = scatter([X, Y, Z, C], ...)
%     [H, Range] = scatter(Range, [X, Y], ...)
%     [H, Range] = scatter(Range, [X, Y, Z], ...)
%     [H, Range] = scatter(Range, [X, Y, Z, C], ...)
%     [H, Range] = scatter(Ax, Range, [X, Y], ...)
%     [H, Range] = scatter(Ax, Range, [X, Y, Z], ...)
%     [H, Range] = scatter(Ax, Range, [X, Y, Z, C], ...)
%
% Input arguments
% ================
%
% * `Ax` [ numeric ] - Handle to axes in which the graph will be plotted; if
% not specified, the current axes will used.
%
% * `Range` [ numeric | char ] - Date range; if not specified the entire
% range of the input tseries object will be plotted.
%
% * `[X, Y, Z, C]` [ tseries ] - Requires the axes X and Y, and optionally
% accepts Z to control the size of the elements, and optionally accepts C 
% to control the colour. 
%
% Output arguments
% =================
%
% * `H` [ numeric ] - Handles to the lines plotted.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `scatter` for all options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% AREA, BAND, BAR, BARCON, BUBBLE, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

% TODO: Add help on date format related options.

%--------------------------------------------------------------------------

[~, varargout{1:nargout}] = tseries.implementPlot(@scatter, varargin{:});

end%

