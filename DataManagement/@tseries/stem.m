function varargout = stem(varargin)
% stem  Plot tseries as discrete sequence data.
%
% Syntax
% =======
%
%     [H, Range] = stem(X, ...)
%     [H, Range] = stem(Range, X, ...)
%     [H, Range] = stem(Ax, Range, X, ...)
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
% a stem graph.
%
% Output arguments
% =================
%
% * `H` [ handle | numeric ] - Handles to stems plotted.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `stem` for all options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

%--------------------------------------------------------------------------

[~, varargout{1:nargout}] = tseries.implementPlot(@stem, varargin{:});

end%

