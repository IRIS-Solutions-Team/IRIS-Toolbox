function [scatterHandle, arrowHandle, dates] = bubble(varargin)
% bubble  Bubble graph for time series
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted
%
%     [scatterHandle, arrowHandle, dates] = bubble([X, Y], ...)
%     [scatterHandle, arrowHandle, dates] = bubble([X, Y, Z], ...)
%     [scatterHandle, arrowHandle, dates] = bubble([X, Y, Z, C], ...)
%     [scatterHandle, arrowHandle, dates] = bubble(~dates, [X, Y], ...)
%     [scatterHandle, arrowHandle, dates] = bubble(~dates, [X, Y, Z], ...)
%     [scatterHandle, arrowHandle, dates] = bubble(~dates, [X, Y, Z, C], ...)
%     [scatterHandle, arrowHandle, dates] = bubble(~axesHandle, ~dates, [X, Y], ...)
%     [scatterHandle, arrowHandle, dates] = bubble(~axesHandle, ~dates, [X, Y, Z], ...)
%     [scatterHandle, arrowHandle, dates] = bubble(~axesHandle, ~dates, [X, Y, Z, C], ...)
%
%
% __Input Arguments__
%
% * `~axesHandle` [ handle | numeric ] - Handle to axes in which the graph
% will be plotted; if not specified, the current axes will used.
%
% * `~dates` [ numeric | char ] - Dates to be plotted; if not specified the
% entire date range of the input time series will be plotted.
%
% * `[X, Y, Z, C]` [ tseries ] - Requires the axes X and Y, and optionally
% accepts Z to control the size of the elements in the scatter plot, and
% optionally accepts C to control the color. 
%
%
% __Output Arguments__
%
% * `scatterHandle` [ handle | numeric ] - Handles to scatter plot.
%
% * `arrowHandle` [ cell ] - Cell array of handles to arrows. 
%
% * `Range` [ numeric ] - Actually plotted date dates.
%
%
% __Options__
%
% `ArrowOptions={ }` [ cell ] - Graphics options for arrow annotationa
% objects connecting individual bubbles.
%
% See help on [`tseries/plot`](tseries/plot) for all options available.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

DEFAULT_ARROW_OPTIONS = { 'LineWidth'; 0.5 };

[axesHandle, dates, this, plotSpec, varargin] = ...
    TimeSubscriptable.preparePlot(varargin{:});

persistent parser
if isempty(parser)
    parser = extend.InputParser('TimeSubscriptable.bubble');
    parser.addParameter({'ArrowOptions', 'Arrow'}, cell.empty(1, 0), @(x) iscell(x) && iscellstr(x(1:2:end)));
end
parser.parse(varargin{:});
opt = parser.Options;
unmatchedOptions = parser.UnmatchedInCell;

%--------------------------------------------------------------------------

% Plot scatter points
plotSpec = [{'filled'}, plotSpec];
[scatterHandle, dates] = scatter(axesHandle, dates, this, plotSpec, unmatchedOptions{:}) ;

% Draw arrows from Xf(1), Yf(1) to Xf(2), Yf(2)
XX = this.Data ;
XX = XX(all(~isnan(XX), 2), :) ;
Xd = [XX(1:end-1, 1), XX(2:end, 1)] ;
Yd = [XX(1:end-1, 2), XX(2:end, 2)] ;
[Xf, Yf] = thirdparty.ds2nfu(axesHandle, Xd, Yd) ;
nx = size(XX, 1) ;
arrowHandle = gobjects(nx-1, 1) ;
for ii = 1:nx-1
    arrowHandle(ii) = annotation( 'Arrow', Xf(ii, :), Yf(ii, :), ...
                                  DEFAULT_ARROW_OPTIONS{:}, ...
                                  opt.ArrowOptions{:} );
end

end%
