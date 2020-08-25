% databank.toTable  Retrieve time series from databank and arrange them in a table
%{
% Syntax
%--------------------------------------------------------------------------
%
% Input arguments marked with a `~` may be omitted 
%
%     outputTable = databank.toTable(inputDb, ~names, ~dates, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`inputDb`__ [ struct | Dictionary ]
%
%>    Input databank from which the time series (specified by their
%>    `names`) will be extracted. 
%
%
% __`~names`__ [ string | `@all` ] 
%
%>    Names of time series that will be extracted from the `inputDb`;
%>    `@all` means all time series found in the `inputDb`; if omitted,
%>    `names=@all`.
%
%
% __`~dates`__ [ DateWrapper | `"longRange"` | `"shortRange"` | "`head`" | "`tail`" ]
%
%>     Dates for which the time series observations will be retrieved, 
%>     with the following four text specifications:
%>
%>     * `"longRange"` means a range from the earliest start date to the
%>     latest end date found amongst all the named time series; 
%>
%>     * `"shortRange"` means a range from the latest start date to the
%>     earliest end date found; 
%>   
%>     * `"head"` means that a `"longRange"` table is first compiled, and
%>     then the standard `head` table method is applied (i.e. preserving
%>     only the first eight rows);
%>
%>     * `"tail"` means that a `"longRange"` table is first compiled, and
%>     then the standard `tail` table method is applied (preserving only
%>     the last eight fows of the table).
%>
%>     If omitted, `dates="longRange"`.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`outputTable`__ [ table ]
%
%>    Output table with the observations from the names time series at the
%>    specified dates organized in columns.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Examples
%--------------------------------------------------------------------------
%
%     >> d = struct( );
%     >> d.x = Series(qq(2020,1):qq(2025,4), @rand);
%     >> d.y = Series(qq(2021,1):qq(2025,1), @rand);
%     >> d.z = Series(qq(2020,3):qq(2026,1), @rand);
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function outputTable = toTable(inputDb, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('databank/toTimetable');
    addRequired(pp, 'inputDb', @validate.databank);
    addOptional(pp, 'names', @all, @(x) isequal(x, @all) || isstring(x) || iscellstr(x) || ischar(x));
    addOptional(pp, 'dates', "longRange", @(x) (isstring(x) && matches(x, ["longRange", "shortRange", "head", "tail"], "ignoreCase", true) || DateWrapper.validateProperRangeInput));
    addParameter(pp, 'Timetable', false, @(x) isequal(x, true) || isequal(x, false));
end
%)
opt = parse(pp, inputDb, varargin{:});
names = pp.Results.names;
dates = pp.Results.dates;

%--------------------------------------------------------------------------

if isequal(names, @all)
    names = databank.filter(inputDb, "Class=", "Series");
end
names = reshape(string(names), 1, [ ]);

if isa(inputDb, 'Dictionary')
    allSeries = arrayfun(@(n) retrieve(inputDb, n), names, "uniformOutput", false);
else
    allSeries = arrayfun(@(n) inputDb.(n), names, "uniformOutput", false);
end

[dates, transform] = locallyResolveDates(dates);
        
data = cell(size(allSeries));
[dates, data{:}] = getDataFromMultiple(dates, allSeries{:});
dates = reshape(dates, [ ], 1);
dt = dater.toMatlab(dates);

if opt.Timetable
    outputTable = timetable(dt, data{:}, 'VariableNames', names);
else
    outputTable = table(dt, data{:}, 'VariableNames', ["Time", names]);
end

if ~isempty(transform)
    outputTable = transform(outputTable);
end

end%

%
% Local Functions
%

function [dates, transform] = locallyResolveDates(dates)
    transform = [ ];
    if isstring(dates)
        if matches(dates, "head", "ignoreCase", true)
            transform = @head;
            dates = "longRange";
        elseif matches(dates, "tail", "ignoreCase", true)
            transform = @tail;
            dates = "longRange";
        end
    end
end%

