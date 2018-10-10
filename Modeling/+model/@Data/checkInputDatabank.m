function output = ...
    checkInputDatabank(this, inputDatabank, range, requiredNames, optionalNames)
    
nv = this.NumVariants;

if isa(requiredNames, 'string')
    requiredNames = cellstr(requiredNames);
end

if nargin<5
    optionalNames = cell.empty(1, 0);
elseif isa(optionalNames, 'string')
    optionalNames = cellstr(optionalNames);
end

freq = DateWrapper.getFrequencyAsNumeric(range);
DateWrapper.checkMixedFrequency(freq);
requiredFreq = freq(1);

allNames = [requiredNames, optionalNames];
indexOptionalNames = [false(size(requiredNames)), true(size(optionalNames))];
indexRequiredNames = [true(size(requiredNames)), false(size(optionalNames))];

checkIncluded = true(size(allNames));
checkFrequency = true(size(allNames));
for i = 1 : numel(allNames)
    ithName = allNames{i};
    if ~isfield(inputDatabank, ithName) || ~isa(inputDatabank.(ithName), 'TimeSubscriptable')
        checkIncluded(i) = ~indexRequiredNames(i);
        continue
    end
    checkFrequency(i) = inputDatabank.(ithName).Frequency==requiredFreq;
end

assert( ...
    all(checkIncluded), ...
    'model:Abstract:checkInputDatabank', ...
    'This time series is missing from input databank: %s \n', ...
    allNames{~checkIncluded} ...
);

assert( ...
    all(checkFrequency), ...
    'model:Abstract:checkInputDatabank', ...
    'This time series has wrong date frequency in input databank: %s \n', ...
    allNames{~checkFrequency} ...
);

numDataSets = databank.numColumns(inputDatabank, allNames);
numDataSets(isnan(numDataSets) & indexOptionalNames) = 0;

checkNumOfDataSetsAndVariants = numDataSets==1 | numDataSets==0 | numDataSets==nv;
assert( ...
    all(checkNumOfDataSetsAndVariants), ...
    'model:Abstract:checkInputDatabank', ...
    'This time series has an invalid number of data sets: %s \n', ...
    allNames{~checkNumOfDataSetsAndVariants} ...
);

output = struct( );
output.NumDataSets = int64(max(numDataSets));

end
