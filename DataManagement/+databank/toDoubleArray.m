function [outputArray, inxOfValid] = toDoubleArray(inputDatabank, names, dates, column)

if nargin<4
    column = 1;
end

persistent parser
if isempty(parser)
    isRound = @(x) isnumeric(x) && all(x==round(x));
    parser = extend.InputParser('databank.toDoubleArray');
    parser.addRequired('InputDatabank', @(x) isstruct(x) && length(x)==1); 
    parser.addRequired('Names', @(x) isa(x, 'string') && isrow(x)); 
    parser.addRequired('Dates', @(x) isa(x, 'Date') && all(isfinite(x)));
    parser.addRequired('Column', @(x) isnumeric(x) && numel(x)==1 && x==round(x)); 
end
parser.parse(inputDatabank, names, dates, column);

%--------------------------------------------------------------------------

numOfNames = numel(names);
numOfDates = numel(dates);

if numOfNames==0
    outputArray = double.empty(numOfDates, 0);
    return
end

freq = DateWrapper.getFrequencyAsNumeric(dates);
inxOfValid = true(1, numOfNames);
for i = 1 : numOfNames
    iName = char(names(i));
    inxOfValid(i) = isfield(inputDatabank, iName) ...
                    && isa(inputDatabank.(iName), 'TimeSubscriptable') ...
                    && ~isnad(inputDatabank.(iName)) ...
                    && inputDatabank.(iName).FrequencyAsNumeric==freq ...
                    && isnumeric(inputDatabank.(iName));
end

outputArray = nan(numOfDates, numOfNames);
outputArray(:, inxOfValid) = databank.toDoubleArrayNoFrills(inputDatabank, names(inxOfValid), dates, column);

end%
