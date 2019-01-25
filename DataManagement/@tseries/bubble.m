function [h1, h2, range] = bubble(varargin)
% bubble  Bubble graph for tseries objects.
%
% Syntax
% =======
%
%     [H1, H2, Range] = bubble([X, Y], ...)
%     [H1, H2, Range] = bubble([X, Y, Z], ...)
%     [H1, H2, Range] = bubble([X, Y, Z, C], ...)
%     [H1, H2, Range] = bubble(Range, [X, Y], ...)
%     [H1, H2, Range] = bubble(Range, [X, Y, Z], ...)
%     [H1, H2, Range] = bubble(Range, [X, Y, Z, C], ...)
%     [H1, H2, Range] = bubble(Ax, Range, [X, Y], ...)
%     [H1, H2, Range] = bubble(Ax, Range, [X, Y, Z], ...)
%     [H1, H2, Range] = bubble(Ax, Range, [X, Y, Z, C], ...)
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
% * `[X, Y, Z, C]` [ tseries ] - Requires the axes X and Y, and optionally
% accepts Z to control the size of the elements in the scatter plot, and
% optionally accepts C to control the colour. 
%
% Output arguments
% =================
%
% * `H1` [ handle | numeric ] - Handles to scatter plot.
%
% * `H2` [ cell ] - Cell array of handles to arrows. 
%
% * `Range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% See help on [`tseries/plot`](tseries/plot) for all options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

% AREA, BAND, BAR, BARCON, BUBBLE, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

[ax, range, this, plotSpec, varargin] = irisinp.parser.parse('tseries.plot', varargin{:});

% Store current `hold` settings.
fig = get(ax, 'parent');
figNextPlot = get(fig, 'nextPlot');
axNextPlot = get(ax, 'nextPlot');
appPlotHoldStyle = getappdata(ax, 'PlotHoldStyle');

% Hold all.
set(fig, 'NextPlot', 'add');
set(ax, 'NextPlot', 'add');
setappdata(ax, 'PlotHoldStyle', true);

% Plot scatter points
plotSpec = ['filled'; plotSpec(:)] ;
[h1, range] = scatter(ax, range, this, plotSpec{:}) ;

XX = this.data ;
XX = XX(all(~isnan(XX), 2), :) ;
Xd = [XX(1:end-1, 1), XX(2:end, 1)] ;
Yd = [XX(1:end-1, 2), XX(2:end, 2)] ;
[Xf, Yf] = thirdparty.ds2nfu(ax, Xd, Yd) ;
% from Xf(1), Yf(1) to Xf(2), Yf(2)
nx = size(XX, 1) ;
h2 = cell(nx-1, 1) ;
for ii = 1:nx-1
    h2 = annotation('arrow', Xf(ii, :), Yf(ii, :)) ;
    h2{ii} = h2 ;
end

% Restore hold settings.
set(fig, 'NextPlot', figNextPlot);
set(ax, 'NextPlot', axNextPlot);
setappdata(ax, 'PlotHoldStyle', appPlotHoldStyle);

end
