function outputTable = toTable(inputDatabank, sourceOfNames, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank/toTimetable');
    parser.addRequired('InputDatabank', @(x) isstruct(x) && numel(x)==1);
    parser.addRequired('SourceOfNames', @(x) isa(x, 'model.Abstract') || isa(x, 'string'));
    parser.addOptional('Dates', Inf, @(x) isequal(x, Inf) || isa(x, 'Date'));
    parser.addParameter('Timetable', false, @(x) isequal(x, true) || isequal(x, false));
end
parser.parse(inputDatabank, sourceOfNames, varargin{:});
dates = parser.Results.Dates;
isTimetable = parser.Results.Timetable;

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
dt = DateWrapper.toDatetime(dates);

if isTimetable
    outputTable = timetable(dt, data{:}, 'VariableNames', cellstr(names));
else
    outputTable = table(dt, data{:}, 'VariableNames', [{'Time'}, cellstr(names)]);
end

end
