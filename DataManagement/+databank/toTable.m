function outputTable = toTable(inputDb, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('databank/toTimetable');
    addRequired(pp, 'inputDb', @validate.databank);
    addOptional(pp, 'names', @all, @(x) isa(x, 'function_handle') || isstring(x) || iscellstr(x) || ischar(x));
    addOptional(pp, 'dates', "longRange", @(x) (isstring(x) && startsWith(x, ["longRange", "shortRange", "head", "tail"], "ignoreCase", true) || validate.properRange));

    addParameter(pp, 'Timetable', false, @(x) isequal(x, true) || isequal(x, false));
end
%)
opt = parse(pp, inputDb, varargin{:});
names = pp.Results.names;
dates = pp.Results.dates;

%--------------------------------------------------------------------------

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

