function varargout = area(varargin)
% area  Area graph for tseries objects.
%
% Syntax
% =======
%
%     [H,Range] = area(X,...)
%     [H,Range] = area(Range,X,...)
%     [H,Range] = area(Ax,Range,X,...)
%
% Input arguments
% ================
%
% * `Ax` [ handle | numeric ] - Handle to axes in which the graph will be
% plotted; if not specified, the current axes will used.
%
% * `Range` [ numeric | char ] - Date range; if not specified the entire
% range of the input tseries object will be plotted.
%
% * `X` [ tseries ] - Input tseries object whose columns will be plotted as
% an area graph.
%
% Output arguments
% =================
%
% * `H` [ handle | numeric ] - Handles to areas plotted.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `area` for all options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

%--------------------------------------------------------------------------

[~, varargout{1:nargout}] = tseries.implementPlot(@area, varargin{:});

end%

