function varargout = plot(varargin)
% plot  Line graph for tseries objects
%
% __Syntax__
%
%     [H, Range] = plot(X, ...)
%     [H, Range] = plot(Range, X, ...)
%     [H, Range] = plot(Ax, Range, X, ...)
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
% * `H` [ numeric ] - Handles to lines plotted.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
%
% __Options__
%
% * `DatePosition='centre'` [ `'centre'` | `'end'` | `'start'` ] - Position
% of each date point within a given period span.
%
% * `DateTick=Inf` [ numeric | `Inf` ] - Vector of dates locating tick
% marks on the X-axis; Inf means they will be created automatically.
%
%  `Tight=false` [ `true` | `false` ] - Make the y-axis tight.
%
% See help on built-in `plot` function for other options available.
%
%
% _Date Format Options_
%
% See [`dat2str`](dates/dat2str) for details on date format options.
%
% * `DateFormat=@config` [ char | `@config` ] - Date format string, or
% array of format strings (possibly different for each date); `@config`
% means the date format from the current IRIS configuration will be used.
%
% * `FreqLetters=@config` [ char | `@config` ] - Six letters used to
% represent the six possible frequencies of IRIS dates, in this order:
% yearly, half-yearly, quarterly, bi-monthly, monthly,  and weekly (such as
% the `'Q'` in `'2010Q1'`); `@config` means the frequence letters from the
% current IRIS configuration will be used..
%
% * `Months={'January', ..., 'December'}` [ cellstr | string | `@config` ] - Twelve
% strings representing the names of the twelve months; `@config` means the
% month names from the current IRIS configuration will be used.
%
% * `ConversionMonth=@config` [ numeric | `'last'` | `@config` ] - Month that will
% represent a lower-than-monthly-frequency date if the month is part of the
% date format string; `@config` means the conversion month from the current
% IRIS configuration will be used.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

% TODO: Add help on date format related options.

% TODO: Document the use of half-ranges in plot functions [-Inf, date], 
% [date, Inf].

%--------------------------------------------------------------------------

[~, varargout{1:nargout}] = tseries.implementPlot(@plot, varargin{:});

end%

