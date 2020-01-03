function [outputArray, inxOfValid] = toDoubleArray(inputDatabank, names, dates, column)
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
numOfNames = numel(names);
numOfDates = numel(dates);

if numOfNames==0
    outputArray = double.empty(numOfDates, 0);
    return
end

freq = DateWrapper.getFrequencyAsNumeric(dates(1));
inxOfValid = true(1, numOfNames);
for i = 1 : numOfNames
    iName = names{i};
    inxOfValid(i) = isfield(inputDatabank, iName) ...
                    && isa(inputDatabank.(iName), 'TimeSubscriptable') ...
                    && ~isnan(inputDatabank.(iName).Start) ...
                    && inputDatabank.(iName).FrequencyAsNumeric==freq ...
                    && isnumeric(inputDatabank.(iName).Data);
end

outputArray = nan(numOfDates, numOfNames);
outputArray(:, inxOfValid) = databank.backend.toDoubleArrayNoFrills( inputDatabank, ...
                                                                     names(inxOfValid), ...
                                                                     dates, ...
                                                                     column );

end%

