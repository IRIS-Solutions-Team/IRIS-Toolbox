% toDoubleArray  Retrieve data from time series into numeric array

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [outputArray, inxValid] = toDoubleArray(inputDb, names, dates, columns)

if nargin<4
    columns = 1;
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('+databank/toDoubleArray');
    addRequired(pp, 'inputDb', @(x) validate.databank(x) && isscalar(x)); 
    addRequired(pp, 'names', @(x) iscellstr(x) || ischar(x) || isstring(x));
    addRequired(pp, 'dates', @DateWrapper.validateProperRangeInput);
    addRequired(pp, 'columns', @(x) isnumeric(x) && all(x(:)==round(x(:))) && all(x(:)>=1));
end
%)
parse(pp, inputDb, names, dates, columns);

names = reshape(string(names), 1, [ ]);

%--------------------------------------------------------------------------

dates = double(dates);
numNames = numel(names);
numDates = numel(dates);
numPages = numel(columns);
outputArray = nan(numDates, numNames, numPages);
if isempty(outputArray)
    return
end

freq = dater.getFrequency(dates(1));
inxValid = false(1, numNames);
for i = 1 : numNames
    if isa(inputDb, 'Dictionary')
        if ~lookupKey(inputDb, names(i))
            continue
        end
        field__ = retrieve(inputDb, names(i));
    else
        if ~isfield(inputDb, names(i))
            continue
        end
        field__ = inputDb.(names(i));
    end
    inxValid(i) = isa(field__, 'NumericTimeSubscriptable') ...
        && ~isnan(field__.Start) ...
        && field__.FrequencyAsNumeric==freq ...
        && isnumeric(field__.Data);
end

outputArray(:, inxValid, :) = databank.backend.toDoubleArrayNoFrills( ...
    inputDb, names(inxValid), dates, columns ...
);

end%

