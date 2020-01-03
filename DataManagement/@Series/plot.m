function varargout = plot(varargin)
% plot  Line graph for Series objects
%{
% ## Syntax ##
%
%     [H, range] = plot(inputSeries, ...)
%     [H, range] = plot(range, inputSeries, ...)
%     [H, range] = plot(ax, range, inputSeries, ...)
%
%
% ## Input Arguments ##
%
%
% __`ax`__ [ handle ] 
% >
% Handle to axes in which the graph will be plotted; if not specified, the
% current axes will used.
%
%
% __`range`__ [ DateWrapper | char ] 
% >
% Date range to be plotted; if not specified or if `range=Inf` the
% range will be determined from the input time series.
%
%
% __`inputSeries`__ [ Series ] 
% >
% Input time series whose columns will be plotted as line graphs.
%
%
% __Output Arguments__
%
%
% __`h`__ [ handle ] 
% >
% Handles to lines plotted.
%
%
% __`range`__ [ DateWrapper ] 
% >
% Date range actually plotted.
%
%
% ## Options ##
%
%
% __`DatePosition='centre'`__ [ `'centre'` | `'end'` | `'start'` ] 
% >
% Position of each date point within a given period span.
%
%
% __`DateTick=Inf`__ [ numeric | `Inf` ] 
% >
% Vector of dates locating tick marks on the X-axis; Inf means they will be
% created automatically.
%
%
% __`Smooth=false`__ [ `true` | `false` ]
% >
% Use spline interpolation to make the plotted series smooth.
%
%
% __`Tight=false`__ [ `true` | `false` ] 
% >
% Make the y-axis tight.
%
%
% See help on built-in `plot` function for other options available.
%
%
% ### Date Format Options ###
%
%
% See [`dat2str`](dates/dat2str) for details on date format options.
%
%
% __`DateFormat=@config`__ [ char |  string | `@config` ] 
% >
% Date format string, or array of format strings (possibly different for
% each date); `@config` means the date format from the current IRIS
% configuration will be used.
%
%
% __`FreqLetters=@config`__ [ char | string | `@config` ] 
% >
% Six letters used to represent the six possible frequencies of IRIS dates,
% in this order: yearly, half-yearly, quarterly, bi-monthly, monthly,  and
% weekly (such as the `'Q'` in `'2010Q1'`); `@config` means the frequence
% letters from the current IRIS configuration will be used.
%
%
% __`Months={'January', ..., 'December'}`__ [ cellstr | string | `@config` ] 
% >
% Twelve strings representing the names of the twelve months; `@config`
% means the month names from the current IRIS configuration will be used.
%
%
% __`ConversionMonth=@config`__ [ numeric | `'last'` | `@config` ] 
% >
% Month that will represent a lower-than-monthly-frequency date if the
% month is part of the date format string; `@config` means the conversion
% month from the current IRIS configuration will be used.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

[varargout{1:nargout}] = Series.implementPlot(@plot, varargin{:});

end%

