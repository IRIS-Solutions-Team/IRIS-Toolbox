function varargout = barcon(varargin)
% barcon  Contribution bar graph for time series (Series) objects
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [H, Range] = barcon(~Ax, ~Range, X, ...)
%
%
% __Input Arguments__
%
% * `~Ax` [ handle | numeric ] - Handle to axes in which the graph will be
% plotted; if omitted the chart will be plotted in the current axes.
%
% * `~Range` [ numeric | char ] - Date range; if omitted the chart will be
% plotted for the entire time series range.
%
% * `X` [ Series ] - Input time series whose columns will be plotted as
% a contribution bar graph.
%
%
% __Output Arguments__
%
% * `H` [ handle | numeric ] - Handles to the bar objects plotted.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
%
% __Options__
%
% * `DateFormat=@config` [ char | `@config` ] - Date format string;
% `@config` means the `PlotDateTimeFormat` setting from the current IRIS
% configuration will be used.
%
% * `ColorMap=lines( )` [ numeric ] - Color map to fill the contribution bars.
%
% * `EvenlySpread=false` [ `true` | `false` ] - Colors of the contribution
% bars are evenly spread across the color map.
%
% See help on [`Series/plot`](Series/plot) and the built-in function
% `bar` for other options available.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

[varargout{1:nargout}] = barcon@TimeSubscriptable(varargin{:});

end%

