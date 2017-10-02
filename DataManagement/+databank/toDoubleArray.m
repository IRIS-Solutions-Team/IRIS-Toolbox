function [outputArray, ixValid] = toDoubleArray(inputDatabank, names, dates, column)

if nargin<4
    column = 1;
end

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    isRound = @(x) isnumeric(x) && all(x==round(x));
    INPUT_PARSER = extend.InputParser('databank/toDoubleArray');
    INPUT_PARSER.addRequired('InputDatabank', @(x) isstruct(x) && length(x)==1); 
    INPUT_PARSER.addRequired('Names', @(x) isa(x, 'string') && isrow(x)); 
    INPUT_PARSER.addRequired('Dates', @(x) isa(x, 'Date') && all(isfinite(x)));
    INPUT_PARSER.addRequired('Column', @(x) isnumeric(x) && numel(x)==1 && x==round(x)); 
end

INPUT_PARSER.parse(inputDatabank, names, dates, column);

%--------------------------------------------------------------------------

numberOfNames = numel(names);
numberOfDates = numel(dates);

if numberOfNames==0
    outputArray = double.empty(numberOfDates, 0);
    return
end

frequency = getFrequency(dates);
ixValid = true(1, numberOfNames);
for i = 1 : numberOfNames
    iName = char(names(i));
    ixValid(i) = isfield(inputDatabank, iName) ...
        && isa(inputDatabank.(iName), 'TimeSeries') ...
        && ~isnad(inputDatabank.(iName)) ...
        && inputDatabank.(iName).Frequency==frequency ...
        && isnumeric(inputDatabank.(iName));
end

outputArray = nan(numberOfDates, numberOfNames);
outputArray(:, ixValid) = databank.toDoubleArrayNoFrills(inputDatabank, names(ixValid), dates, column);

end
