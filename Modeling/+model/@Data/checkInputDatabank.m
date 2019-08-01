function databankInfo = checkInputDatabank(this, inputDatabank, range, requiredNames, optionalNames)
    
nv = this.NumOfVariants;

if isempty(requiredNames)
    requiredNames = cell.empty(1, 0);
elseif ~iscellstr(requiredNames)
    requiredNames = cellstr(requiredNames);
end

if nargin<5 || isempty(optionalNames)
    optionalNames = cell.empty(1, 0);
elseif ~iscellstr(optionalNames)
    optionalNames = cellstr(optionalNames);
end

freq = DateWrapper.getFrequencyAsNumeric(range);
DateWrapper.checkMixedFrequency(freq);
requiredFreq = freq(1);

allNames = [requiredNames, optionalNames];
inxOfOptionalNames = [false(size(requiredNames)), true(size(optionalNames))];
inxOfRequiredNames = [true(size(requiredNames)), false(size(optionalNames))];

checkIncluded = true(size(allNames));
checkFrequency = true(size(allNames));
for i = 1 : numel(allNames)
    ithName = allNames{i};
    if ~isfield(inputDatabank, ithName)
        continue
    end
    ithField = inputDatabank.(ithName);
    if ~isa(ithField, 'TimeSubscriptable')
        checkIncluded(i) = ~inxOfRequiredNames(i);
        continue
    end
    if isempty(ithField)
        continue
    end
    ithFreq = getFrequencyAsNumeric(ithField);
    checkFrequency(i) = isnan(ithFreq) || ithFreq==requiredFreq;
end

if ~all(checkIncluded)
    THIS_ERROR = { 'model:Abstract:checkInputDatabank', ...
                   'This time series is missing from input databank: %s ' };
    throw( exception.Base(THIS_ERROR, 'error'), ...
           allNames{~checkIncluded} );
end

if ~all(checkFrequency)
    THIS_ERROR = { 'model:Abstract:checkInputDatabank', ...
                   'This time series has the wrong date frequency in input databank: %s ' };
    throw( exception.Base(THIS_ERROR, 'error'), ...
           allNames{~checkFrequency} );
end

numOfPages = databank.numOfColumns(inputDatabank, allNames);
numOfPages(isnan(numOfPages) & inxOfOptionalNames) = 0;
maxNumOfPages = max(numOfPages);

checkNumOfPagesAndVariants = numOfPages==1 ...
                              | numOfPages==0 ...
                              | (nv>1 & numOfPages==nv) ...
                              | (nv==1 & numOfPages==maxNumOfPages);

if ~all(checkNumOfPagesAndVariants)
    THIS_ERROR = { 'model:Abstract:checkInputDatabank'
                   'This time series has an inconsistent number of columns: %s ' };
    throw( exception.Base(THIS_ERROR, 'error'), ...
           allNames{~checkNumOfPagesAndVariants} );
end

databankInfo = struct( );
databankInfo.NumOfPages = max(max(numOfPages), 1);

end%

