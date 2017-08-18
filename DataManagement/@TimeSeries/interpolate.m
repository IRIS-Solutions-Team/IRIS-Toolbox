function this = interpolate(this, newDates, varargin)

persistent INPUT_PARSER

if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('TimeSeries/interpolate');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'TimeSeries'));
    INPUT_PARSER.addRequired('InterpDates', @(x) isequal(x, Inf) || isa(x, 'Date'));
    INPUT_PARSER.addParameter('Method', 'linear', @(x) ischar(x) || isstring(x));
end

INPUT_PARSER.parse(this, newDates, varargin{:});
opt = INPUT_PARSER.Results;

if isnad(this.Start)
    return
end

if isequal(newDates, Inf)
    newDates = this.Range;
else
    assert( ...
        this.Frequency==getFrequency(newDates), ...
        'TimeSeries:interpolate', ...
        'Invalid frequency of interpolation dates' ...
    );
end

%--------------------------------------------------------------------------

missingTest = this.MissingTest;
range = this.Range;
data = this.Data;
sizeData = size(data);
ndimsData = length(sizeData);
data = data(:, :);
numberOfColumns = size(data, 2);

newDates = vec(newDates);
numberOfNewDates = numel(newDates); 

newData = repmat(this.MissingValue, numberOfNewDates, numberOfColumns);
for ithColumn = 1 : numberOfColumns
    ithData = data(:, ithColumn);
    ixAvailable = ~missingTest(ithData);
    ithDates = range(ixAvailable);
    ithData = ithData(ixAvailable);
    newData(:, ithColumn) = interp1(ithDates.Serial, ithData, newDates.Serial, opt.Method, 'extrap');
end

if ndimsData>2
    newData = reshape(newData, [numberOfNewDates, sizeData(2:end)]);
end

this = setData(this, {newDates}, newData);
this = trim(this);

end
