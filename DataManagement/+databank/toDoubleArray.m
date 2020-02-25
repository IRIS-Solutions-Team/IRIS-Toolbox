function [outputArray, inxValid] = toDoubleArray(inputDatabank, names, dates, column)
% toDoubleArray  Retrieve data from time series into numeric array

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if nargin<4
    column = 1;
end

persistent parser
if isempty(parser)
    isRound = @(x) isnumeric(x) && all(x==round(x));
    parser = extend.InputParser('databank.toDoubleArray');
    parser.addRequired('InputDatabank', @(x) isstruct(x) && length(x)==1); 
    parser.addRequired('Names', @(x) iscellstr(x) || ischar(x) || (isa(x, 'string') && isrow(x)));
    parser.addRequired('Dates', @DateWrapper.validateDateInput);
    parser.addRequired('Column', @(x) isnumeric(x) && numel(x)==1 && x==round(x)); 
end
parser.parse(inputDatabank, names, dates, column);

if ~iscellstr(names)
    names = cellstr(names);
end

%--------------------------------------------------------------------------

dates = double(dates);
numNames = numel(names);
numDates = numel(dates);

if numNames==0
    outputArray = double.empty(numDates, 0);
    return
end

freq = DateWrapper.getFrequencyAsNumeric(dates(1));
inxValid = true(1, numNames);
for i = 1 : numNames
    name__ = names{i};
    inxValid(i) = isfield(inputDatabank, name__) ...
        && isa(inputDatabank.(name__), 'TimeSubscriptable') ...
        && ~isnan(inputDatabank.(name__).Start) ...
        && inputDatabank.(name__).FrequencyAsNumeric==freq ...
        && isnumeric(inputDatabank.(name__).Data);
end

outputArray = nan(numDates, numNames);
outputArray(:, inxValid) = databank.backend.toDoubleArrayNoFrills( ...
    inputDatabank ...
    , names(inxValid) ...
    , dates ...
    , column ...
);

end%

