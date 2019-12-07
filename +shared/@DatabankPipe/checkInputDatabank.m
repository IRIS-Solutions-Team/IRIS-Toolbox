function databankInfo = checkInputDatabank(this, inputDatabank, range, requiredNames, optionalNames, context)
% checkInputDatabank  Check input databank for missing or non-compliant variables
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

if nargin<6
    context = "";
end

%--------------------------------------------------------------------------
    
nv = countVariants(this);

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
inxOptionalNames = [false(size(requiredNames)), true(size(optionalNames))];
inxRequiredNames = [true(size(requiredNames)), false(size(optionalNames))];

checkIncluded = true(size(allNames));
checkFrequency = true(size(allNames));
for i = 1 : numel(allNames)
    ithName = allNames{i};
    try
        ithField = getfield(inputDatabank, ithName);
    catch
        ithField = NaN;
    end
    if ~isa(ithField, 'TimeSubscriptable')
        checkIncluded(i) = ~inxRequiredNames(i);
        continue
    end
    if isempty(ithField)
        continue
    end
    ithFreq = getFrequencyAsNumeric(ithField);
    checkFrequency(i) = isnan(ithFreq) || ithFreq==requiredFreq;
end

if ~all(checkIncluded)
    thisError = [ "DatabankPipe:MissingSeries"
                  "This time series is required " + context + " "
                  "but missing from the input databank: %s " ];
    throw( exception.Base(thisError, 'error'), ...
           allNames{~checkIncluded} );
end

if ~all(checkFrequency)
    thisError = { 'model:Abstract:checkInputDatabank', ...
                   'This time series has the wrong date frequency in the input databank: %s ' };
    throw( exception.Base(thisError, 'error'), ...
           allNames{~checkFrequency} );
end

numPages = databank.backend.numOfColumns(inputDatabank, allNames);
numPages(isnan(numPages) & inxOptionalNames) = 0;
maxNumPages = max(numPages);

checkNumPagesAndVariants = numPages==1 ...
                         | numPages==0 ...
                         | (nv>1 & numPages==nv) ...
                         | (nv==1 & numPages==maxNumPages);

if ~all(checkNumPagesAndVariants)
    thisError = { 'model:Abstract:checkInputDatabank'
                   'This time series has an inconsistent number of columns: %s ' };
    throw( exception.Base(thisError, 'error'), ...
           allNames{~checkNumPagesAndVariants} );
end

databankInfo = struct( );
databankInfo.NumOfPages = max(max(numPages), 1);

end%

