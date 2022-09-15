function outputTable = toTable(inputDb, varargin)

%(
persistent ip
if isempty(ip)
    ip = extend.InputParser('databank/toTimetable');
    addRequired(ip, 'inputDb', @validate.databank);
    addOptional(ip, 'names', @all, @(x) isa(x, 'function_handle') || isstring(x) || iscellstr(x) || ischar(x));
    addOptional(ip, 'dates', "longRange", @(x) (isstring(x) && startsWith(x, ["longRange", "shortRange", "head", "tail"], "ignoreCase", true) || validate.properRange));
    addParameter(ip, 'Timetable', false, @(x) isequal(x, true) || isequal(x, false));
end
opt = parse(ip, inputDb, varargin{:});
names = ip.Results.names;
dates = ip.Results.dates;
%)


    [data, names, dates, transform] = databank.backend.extractSeriesData(inputDb, names, dates);
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

    if ~isempty(transform)
        outputTable = transform(outputTable);
    end

end%

