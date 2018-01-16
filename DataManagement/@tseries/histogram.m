function varargout = histogram(varargin)
% histogram  Histogram plot for tseries objects.
%
% Syntax
% =======
%
%     [H,Range] = histogram(X,...)
%     [H,Range] = histogram(Range,X,...)
%     [H,Range] = histogram(Ax,Range,X,...)
%
%
% Input arguments
% ================
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
% Output arguments
% =================
%
% * `H` [ numeric ] - Handles to histogram object.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
%
% Options
% ========
%
% * `'datePosition='` [ *`'centre'`* | `'end'` | `'start'` ] - Position of
% each date point within a given period span.
%
% * `'dateTick='` [ numeric | *`Inf`* ] - Vector of dates locating tick
% marks on the X-axis; Inf means they will be created automatically.
%
% * `'tight='` [ `true` | *`false`* ] - Make the y-axis tight.
%
% See help on built-in `plot` function for other options available.
%
%
% Date format options
% ====================
%
% See [`dat2str`](dates/dat2str) for details on date format options.
%
% * `'dateFormat='` [ char | cellstr | *`'YYYYFP'`* ] - Date format string,
% or array of format strings (possibly different for each date).
%
% * `'freqLetters='` [ char | *`'YHQBMW'`* ] - Six letters used to
% represent the six possible frequencies of IRIS dates, in this order:
% yearly, half-yearly, quarterly, bi-monthly, monthly,  and weekly (such as
% the `'Q'` in `'2010Q1'`).
%
% * `'months='` [ cellstr | *`{'January',...,'December'}`* ] - Twelve
% strings representing the names of the twelve months.
%
% * `'ConversionMonth='` [ numeric | `'last'` | *`1`* ] - Month that will
% represent a lower-than-monthly-frequency date if the month is part of the
% date format string.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM, HISTOGRAM

% TODO: Add help on date format related options.

% TODO: Document the use of half-ranges in plot functions [-Inf,date],
% [date,Inf].

[ax, range, x, plotSpec, varargin] = ...
    irisinp.parser.parse('tseries.plot',varargin{:});

[opt, varargin] = passvalopt('tseries.plot',varargin{:});

%--------------------------------------------------------------------------

[~, varargout{1:nargout}] = ...
    tseries.myplot(@histogram, ax, range, [ ], x, plotSpec, opt, varargin{:});

end
