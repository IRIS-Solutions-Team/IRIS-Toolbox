function varargout = histogram(varargin)
% histogram  Histogram plot for tseries objects
%
% __Syntax__
%
%     [H,Range] = histogram(X,...)
%     [H,Range] = histogram(Range,X,...)
%     [H,Range] = histogram(Ax,Range,X,...)
%
%
% __Input Arguments__
%
% * `Ax` [ numeric ] - Handle to axes in which the graph will be plotted;
% if not specified, the current axes will used.
%
% * `Range` [ numeric | char ] - Date range; if not specified the entire
% range of the input tseries object will be plotted.
%
% * `X` [ tseries ] - Input tseries object whose columns will be plotted as
% a line graph.
%
%
% __Output Arguments__
%
% * `H` [ numeric ] - Handles to histogram object.
%
% * `Range` [ numeric ] - Actually plotted date range.
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
% * `Tight=false` [ `true` | `false` ] - Make the y-axis tight.
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
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM, HISTOGRAM

% TODO: Add help on date format related options.

% TODO: Document the use of half-ranges in plot functions [-Inf,date],
% [date,Inf].

%--------------------------------------------------------------------------

[~, varargout{1:nargout}] = tseries.implementPlot(@histogram, arargin{:});

end%

