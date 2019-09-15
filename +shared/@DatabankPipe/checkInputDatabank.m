function databankInfo = checkInputDatabank(this, inputDatabank, range, requiredNames, optionalNames)
% checkInputDatabank  Check input databank for missing or non-compliant variables
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------
    
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
    thisError = { 'model:Abstract:checkInputDatabank', ...
                   'This time series is missing from input databank: %s ' };
    throw( exception.Base(thisError, 'error'), ...
           allNames{~checkIncluded} );
end

if ~all(checkFrequency)
    thisError = { 'model:Abstract:checkInputDatabank', ...
                   'This time series has the wrong date frequency in input databank: %s ' };
    throw( exception.Base(thisError, 'error'), ...
           allNames{~checkFrequency} );
end

numPages = databank.backend.numOfColumns(inputDatabank, allNames);
numPages(isnan(numPages) & inxOfOptionalNames) = 0;
maxNumOfPages = max(numPages);

checkNumOfPagesAndVariants = numPages==1 ...
                              | numPages==0 ...
                              | (nv>1 & numPages==nv) ...
                              | (nv==1 & numPages==maxNumOfPages);

if ~all(checkNumOfPagesAndVariants)
    thisError = { 'model:Abstract:checkInputDatabank'
                   'This time series has an inconsistent number of columns: %s ' };
    throw( exception.Base(thisError, 'error'), ...
           allNames{~checkNumOfPagesAndVariants} );
end

databankInfo = struct( );
databankInfo.NumOfPages = max(max(numPages), 1);

end%

