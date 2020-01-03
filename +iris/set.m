function set(varargin)
% iris.set  Change IRIS configuration settings
%
% __Syntax__
%
%     iris.set(Name, Value)
%     iris.set(Name, Value, Name, Value, ...)
%
%
% __Input Arguments__
%
% * `Name` [ char ] - Name of the IRIS configuration settings that will be
% modified.
%
% * `Value` [ ... ] - New value that will be assigned to the settings.
%
%
% __Modifiable IRIS Configuration Options__
%
% _Dates and Formats_
%
% * `DateFormat=struct('yy','Y','hh','YFP','qq','YFP','bb','YFP','mm','YFP','ww','YFP')` 
% [ struct | char ] - Date format used to display dates in the command
% window, CSV databases, and reports. Note that the default date format for
% graphs is controlled by the `PlotDateFormat=` option. The default 'YFP'
% means that the year, frequency letter, and period is displayed. See also
% help on [`dat2str`](dates/dat2str) for more date formatting details. The
% `DateFormat=` option is also found in many IRIS functions whenever it is
% relevant, and can be used to overwrite the `iris.set` settings.
%
% * `FreqLetters='YHQMW'` [ char | string ] - Five letters used to
% represent the six possible frequencies of IRIS dates, in this order:
% yearly, half-yearly, quarterly, monthly, and weekly (such as the `'Q'` in
% `'2010Q1'`).
%
% * `Months={'January', ..., 'December'}` [ cellstr | string ] - Twelve
% strings representing the names of the twelve months; this option can be
% used whenever you want to replace the default English names with your
% local language.
%
% * `PlotDateFormat=struct('yy','Y','hh','Y:P','qq','Y:P','bb','Y:P','mm','Y:P','ww','Y:P')`
% [ struct | char ] - Default date formats used to display dates in graphs
% including graphs in reports. The default date formats are set
% individually for each of the 6 ate frequencies in a struct with the
% following fields: `.yy`, `.hh`, `.qq`, `.bb`, `.mm`, `.ww`. Dates with
% indeterminate frequency are printed as plain numbers.
%
% * `SeriesFormat=''` [ char | empty ] - Format string for displaying time
% series data on the screen. See help on the Matlab `sprintf` function for
% how to set up format strings. If empty the default format of the
% `num2str` function is used.
%
% * `ConversionMonth='first'` [ numeric | `'first'` | `'last'` ] - Month
% that will represent a lower-than-monthly-frequency date if the month is
% part of the date format string.
%
% * `WDay='Thu'` [ `'Mon'` | `'Tue'` | `'Wed'` | `'Thu'` | `'Fri'` |
% `'Sat'` | `'Sun'` ] - Day of week that will represent weeks in date
% strings, see [`dates/dat2str`](dates/dat2str), and when weekly tseries
% objects are displayed on the screen.
%
%
% _External Tools Used by IRIS_
%
% * `PdfLaTeX=` [ char ] - Location of the PDF LaTeX engine (such as
% pdflatex). This program is called to compile report and publish m-files.
% By default, IRIS attempts to locate `pdflatex.exe` by running TeX's
% `kpsewhich`, and `which` on Unix platforms.
%
% * `EpsToPdfPath=` [ char ] - Location of the `epstopdf.exe` program.
% This program is called to convert EPS graphics files to PDFs in
% reports.
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

if nargin==0
    return
end

if nargin==1
    if ~isa(varargin{1}, 'iris.Configuration')
        error( 'IRIS:Configuration:NotAConfigurationObject', ...
               'If iris.set(~) is called with a single input argument, it must be an iris.Configuration object' );
    end
    irisConfig = varargin{1};
    save(irisConfig);
    return
end

irisConfig = iris.Configuration.load( );

for i = 1 : 2 : numel(varargin)
    ithOptionName = varargin{i};
    ithOptionName = strrep(ithOptionName, '=', '');
    ithNewValue = varargin{i+1};
    irisConfig.(ithOptionName) = ithNewValue;
end

save(irisConfig);

end%

