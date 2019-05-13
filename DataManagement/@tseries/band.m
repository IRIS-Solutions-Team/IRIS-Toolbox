function varargout = band(varargin)
% band  Line-and-band graph for tseries objects.
%
% __Syntax__
%
%     [Ln, Bd, Range] = band(X, Low, High...)
%     [Ln, Bd, Range] = band(Range, X, Low, High, ...)
%     [Ln, Bd, Range] = band(Ax, Range, X, Low, High, ...)
%
%
% __Input Arguments__
%
% * `Ax` [ numeric ] - Handle to axes in which the graph will be plotted;
% if not specified, the current axes will used.
%
% * `Range` [ numeric | char ] - Date range; if not specified the entire
% range of the input time series object will be plotted.
%
% * `X` [ tseries ] - Input time series whose columns will be plotted as
% a line graph (referred to as center lines).
%
% * `Low` [ tseries ] - Time series that defines the lower edge of each
% band.
%
% * `High` [ tseries ] - Time series that defines the upper edge of each
% band plotted.
%
%
% __Output Arguments__
%
% * `Ln` [ numeric ] - Handles to lines plotted.
%
% * `Bd` [ numeric ] - Handles to bands (patch objects) plotted.
%
% * `Range` [ numeric ] - Date range actually plotted.
%
%
% __Options__
%
% * `DatePosition='Center'` [ `'Center'` | `'End'` | `'Start'` ] - Position
% of each date point within a given period span.
%
% * `DateTick=Inf` [ numeric ] - Vector of dates locating tick marks on the
% X-axis; Inf means they will be created automatically.
%
% * `ExcludeFromLegend=true` [ `true` | `false` ] - Exclude bands from
% legend.
%
% * `Grid='Top'` [ `'Bottom'` | `'Top'` ] - Place grid on top or bottom.
%
% * `Relative=true` [ `true` | `false` ] - If `true`, the lower and upper
% edge will be constructed by subtracting `Low` from `X` and adding `High`
% to `X`, respectively; otherwise, `Low` and `High` will be interpreted as
% absolute positions of the edges.
%
% * `Tight=false` [ `true` | `false` ] - Make the y-axis tight.
%
% * `White=0.85` [ numeric ] - Percentage of white color mixed
% with the respective center line color and used to fill the band area.
%
% See help on built-in `plot` function for other options available.
%
%
% __Date Format Options__
%
% See [`dat2str`](dates/dat2str) for details on date format options.
%
% * `DateFormat='YYYYFP'` [ char | cellstr | string ] - Date format string,
% or array of format strings (possibly different for each date).
%
% * `FreqLetters='YHQMW` [ char | string ] - Five letters used to represent
% the six possible frequencies of IRIS dates, in this order: yearly,
% half-yearly, quarterly, monthly,  and weekly (such as the `'Q'` in
% `'2010Q1'`).
%
% * `Months={'January', ..., 'December'}` [ cellstr | string ] - Twelve
% strings representing the names of the twelve months.
%
% * `ConversionMonth=1` [ numeric | `'last'` ] - Month that will
% represent a lower-than-monthly-frequency date if the month is part of the
% date format string.
%
%
% __Description__
%
% If one (or more) of the input time series, `X`, `Low`, or `High`, 
% consists of more than one column, the graph is constructructed as
% follows:
%
% * One column in `X`, multiple columns in `Low` or `High` - multiple bands
% are plotted around a single center line.
%
% * Multiple columns in `X`, one column in `Low` or `High` - a single band
% is plotted around each of the center lines, each band constructed from
% the same lower and upper edge data; this setup makes sense only with the
% option `'relative=' true`.
%
% * Multiple columns in `X`, mutliple columns in `Low` or `High` - a single
% band is plotted around each of the center lines, each band constructed
% from different data.
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

% TODO: Add help on date format related options.

% TODO: Document the use of half-ranges in plot functions [-Inf, date], 
% [date, Inf].

[Ax, Rng, X, Lo, Hi, PlotSpec, varargin] = ...
    irisinp.parser.parse('tseries.band', varargin{:});
[bandOpt, varargin] = passvalopt('tseries.band', varargin{:});

%--------------------------------------------------------------------------

if isempty(PlotSpec)
    PlotSpec = '';
else
    PlotSpec = PlotSpec{1};
end
if isa(Ax, 'function_handle')
    Ax = Ax( );
end
[ax, h, range, cData, xCoor] = tseries.implementPlot(@plot, Ax, Rng, X, PlotSpec, varargin{:});

loData = getData(Lo, range);
hiData = getData(Hi, range);
pt = tseries.myband(ax, h, cData, xCoor, loData, hiData, bandOpt);
set(ax, 'Layer', bandOpt.grid);

% Output arguments passed back to user.
varargout = { h, pt, range, cData, xCoor };

end
