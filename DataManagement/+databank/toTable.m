function outputTable = toTable(inputDatabank, sourceOfNames, varargin)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('databank/toTimetable');
    INPUT_PARSER.addRequired('InputDatabank', @(x) isstruct(x) && numel(x)==1);
    INPUT_PARSER.addRequired('SourceOfNames', @(x) isa(x, 'model.Abstract') || isstring(x));
    INPUT_PARSER.addOptional('Dates', Inf, @(x) isequal(x, Inf) || isa(x, 'Date'));
    INPUT_PARSER.addParameter('Timetable', false, @(x) isequal(x, true) || isequal(x, false));
end

INPUT_PARSER.parse(inputDatabank, sourceOfNames, varargin{:});
dates = INPUT_PARSER.Results.Dates;
isTimetable = INPUT_PARSER.Results.Timetable;

%--------------------------------------------------------------------------

if isa(sourceOfNames, 'AbstractModel')
    names = sourceOfNames.TableNames;
else
    names = sourceOfNames;
end

numberOfNames = numel(names);
ts = cell(1, numberOfNames);
for i = 1 : numberOfNames
    name = char(names(i));
    ts{i} = inputDatabank.(name);
end

data = cell(size(ts));
[dates, data{:}] = getDataFromAll(dates, ts{:});
dates = vec(dates);
dt = datetime(dates);
%dt.Format = [dt.Format, ':'];

if isTimetable
    outputTable = timetable(dt, data{:}, 'VariableNames', cellstr(names));
else
    outputTable = table(dt, data{:}, 'VariableNames', [{'Time'}, cellstr(names)]);
end

end
