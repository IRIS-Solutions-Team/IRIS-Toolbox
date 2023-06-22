%{
% 
% # `databank.toTable` ^^(+databank)^^
% 
% {== Retrieve time series from databank and arrange them in a table ==}
% 
% 
% ## Syntax 
% 
%     outputTable = databank.toTable(inputDb, ~names, ~dates, ...)
% 
% 
% ## Input arguments 
% 
% __`inputDb`__ [ struct | Dictionary ]
% > 
% > Input databank from which the time series (specified by their
% > `names`) will be extracted. 
% > 
% 
% __`~names`__ [ string | `@all` ] 
% > 
% > Names of time series that will be extracted from the `inputDb`;
% > `@all` means all time series found in the `inputDb`; if omitted,
% > `names=@all`.
% > 
% 
% __`~dates`__ [ DateWrapper | `"unbalanced"` | `"balanced"` ]
% > Dates for which the time series observations will be retrieved, 
% > with the following four text specifications:
% > 
% > * `"unbalanced"` means a range from the earliest start date to the
% > latest end date found amongst all the named time series; 
% > 
% > * `"balanced"` means a range from the latest start date to the
% > earliest end date found; 
% > 
% > If omitted, `dates="unbalanced"`.
% 
%
% ## Output arguments 
% 
% __`outputTable`__ [ table ]
% > 
% > Output table with the observations from the names time series at the
% > specified dates organized in columns.
% > 
% 
% ## Options 
% 
% __`zzz=default`__ [ zzz | ___ ]
% > 
% > Description
% > 
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
% ```matlab
% d = struct( );
% d.x = Series(qq(2020,1):qq(2025,4), @rand);
% d.y = Series(qq(2021,1):qq(2025,1), @rand);
% d.z = Series(qq(2020,3):qq(2026,1), @rand);
% ```
% 
%}
% --8<--


function outputTable = toTable(inputDb, varargin)

%(
persistent ip
if isempty(ip)
    ip = inputParser();
    addOptional(ip, 'names', @all, @(x) isa(x, 'function_handle') || isstring(x) || iscellstr(x) || ischar(x));
    addOptional(ip, 'dates', "unbalanced", @(x) any(strcmpi(x, ["unbalanced", "balanced"])) || validate.properRange(x));
    addParameter(ip, 'Timetable', false, @(x) isequal(x, true) || isequal(x, false));
end
parse(ip, varargin{:});
opt = ip.Results;
names = ip.Results.names;
dates = ip.Results.dates;
%)


    [data, names, dates] = databank.backend.extractSeriesData(inputDb, names, dates);
    freq = dater.getFrequency(dates(1));

    dates = reshape(dates, [], 1);
    if freq>0
        dt = dater.toMatlab(dates);
    else
        dt = dates;
    end

    if opt.Timetable && freq>0
        outputTable = timetable(dt, data{:}, 'VariableNames', names);
    else
        outputTable = table(dt, data{:}, 'VariableNames', ["Time", names]);
    end

end%

