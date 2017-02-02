function irisset(varargin)
% irisset  Change configurable IRIS options.
%
%
% Syntax
% =======
%
%
%     irisset(name, value)
%     irisset(name, value, name, value, ...)
%
%
% Input arguments
% ================
%
%
% * `name` [ char ] - Name of the IRIS configuration option that will be
% modified.
%
% * `value` [ ... ] - New value that will be assigned to the option.
%
%
% Modifiable IRIS configuration options
% ======================================
%
%
% Dates and formats
% -------------------
%
%
% * `'DateFormat='` [ char | *`'YPF'`* ] - Date format used to display
% dates in the command window, CSV databases, and reports. Note that the
% default date format for graphs is controlled by the `'PlotDateFormat='`
% option. The default 'YFP' means that the year, frequency letter, and
% period is displayed. See also help on [`dat2str`](dates/dat2str) for more
% date formatting details. The `'DateFormat='` option is also found in many
% IRIS functions whenever it is relevant, and can be used to overwrite the
% `'irisset='` settings.
%
% * `'FreqLetters='` [ char | *`'YHQBMW'`* ] - Six letters used to
% represent the six possible frequencies of IRIS dates, in this order:
% yearly, half-yearly, quarterly, bi-monthly, monthly, and weekly (such as
% the `'Q'` in `'2010Q1'`).
%
% * `'Months='` [ cellstr | *`{'January',...,'December'}`* ] - Twelve
% strings representing the names of the twelve months; this option can be
% used whenever you want to replace the default English names with your
% local language.
%
% * `'PlotDateFormat='` [ char |
% *`struct('yy','Y','hh','Y:P','qq','Y:P','bb','Y:P','mm','Y:P','ww','Y:P')`*
% ] - Default date formats used to display dates in graphs including graphs
% in reports. The default date formats are set individually for each of the
% 6 ate frequencies in a struct with the following fields: `.yy`, `.hh`,
% `.qq`, `.bb`, `.mm`, `.ww`. Dates with indeterminate frequency are
% printed as plain numbers.
%
% * `'TseriesFormat='` [ char | *empty* ] - Format string for displaying
% time series data on the screen. See help on the Matlab `sprintf` function
% for how to set up format strings. If empty the default format of the
% `num2str` function is used.
%
% * `TseriesMaxWSpace='` [ numeric | *`5`* ] - Maximum number of white
% spaces printed between individual columns of a multivariate tseries
% object on the screen.
%
% * `'StandinMonth='` [ numeric | `'last'` | `*1*` ] - Month that will
% represent a lower-than-monthly-frequency date if the month is part of the
% date format string.
%
% * `'wwDay='` [ `'Mon'` | `'Tue'` | `'Wed'` | *`'Thu'`* | `'Fri'` |
% `'Sat'` | `'Sun'` ] - Day of week that will represent weeks in date
% strings, see [`dates/dat2str`](dates/dat2str), and when weekly tseries
% objects are displayed on the screen.
%
%
% External tools used by IRIS
% -----------------------------
%
% * `'PdfLaTeX='` [ char ] - Location of the PDF LaTeX engine (such as
% pdflatex). This program is called to compile report and publish m-files.
% By default, IRIS attempts to locate `pdflatex.exe` by running TeX's
% `kpsewhich`, and `which` on Unix platforms.
%
% * `'EpsToPdfPath='` [ char ] - Location of the `epstopdf.exe` program.
% This program is called to convert EPS graphics files to PDFs in
% reports.
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

irisconfigmaster('set', varargin{:});

end
