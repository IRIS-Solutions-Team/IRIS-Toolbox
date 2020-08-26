% checkInputDatabank  Check input databank for missing or non-compliant variables
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function dbInfo = checkInputDatabank( ...
    this, inputDb, range ...
    , requiredNames, optionalNames, context ...
    , allowedNumeric ...
)

try
    if ~isempty(optionalNames)
        optionalNames = reshape(string(optionalNames), 1, [ ]);
    else
        optionalNames = string.empty(1, 0);
    end
catch
    optionalNames = string.empty(1, 0);
end

try
    context;
catch
    context = "";
end

try
    if ~isequal(allowedNumeric, @all)
        allowedNumeric = reshape(string(allowedNumeric), 1, [ ]);
    end
catch
    allowedNumeric = string.empty(1, 0);
end

%--------------------------------------------------------------------------
    
dbInfo = struct( );
dbInfo.NumPages = NaN;
dbInfo.NamesAvailable = string.empty(1, 0);
if isequal(inputDb, "asynchronous")
    return
end

nv = countVariants(this);

if isempty(requiredNames)
    requiredNames = string.empty(1, 0);
elseif ~iscellstr(requiredNames)
    requiredNames = reshape(string(requiredNames), 1, [ ]);
end

freq = dater.getFrequency(range);
DateWrapper.checkMixedFrequency(freq);
requiredFreq = freq(1);

allNames = [requiredNames, optionalNames];
inxOptionalNames = [false(size(requiredNames)), true(size(optionalNames))];
inxRequiredNames = [true(size(requiredNames)), false(size(optionalNames))];


checkIncluded = true(size(allNames)); % ^[1]
checkFrequency = true(size(allNames)); % ^[2]
checkType = true(size(allNames)); % ^[3]
% [1]: Check that all required names are available
% [2]: Check that all time series have the correct date frequency
% [3]: Check that there is no invalid type of input data

numAllNames = numel(allNames);
namesAvailable = string.empty(1, 0);
namesInputDb = keys(inputDb);
numPages = nan(1, numAllNames);
for i = 1 : numAllNames
    name__ = allNames(i);
    allowedNumeric__ = isequal(allowedNumeric, @all) || any(name__==allowedNumeric);
    if ~any(name__==namesInputDb)
        checkIncluded(i) = ~inxRequiredNames(i);
        continue
    end
    if isa(inputDb, 'Dictionary')
        field__ = retrieve(inputDb, name__);
    else
        field__ = inputDb.(name__);
    end
    if isa(field__, 'NumericTimeSubscriptable')
        if ~isempty(field__)
            freq__ = getFrequencyAsNumeric(field__);
            checkFrequency(i) = isnan(freq__) || freq__==requiredFreq;
        end
        namesAvailable(end+1) = string(name__);
        sizeField__ = size(field__.Data);
        numPages(i) = prod(sizeField__(2:end));
        continue
    end
    if (isnumeric(field__) || islogical(field__)) && allowedNumeric__ && isrow(field__)
        namesAvailable(end+1) = string(name__);
        sizeField__ = size(field__);
        numPages(i) = prod(sizeField__(2:end));
        continue
    end
    checkType(i) = false;
end

if ~all(checkIncluded)
    hereReportMissing( );
end

if ~all(checkFrequency)
    hereReportInvalidFrequency( );
end

if ~all(checkType)
    hereReportInvalidType( );
end

numPages(isnan(numPages) & inxOptionalNames) = 0;
maxNumPages = max(numPages);

checkNumPagesAndVariants ...
    = numPages==1 ...
    | numPages==0 ...
    | (nv>1 & numPages==nv) ...
    | (nv==1 & numPages==maxNumPages);

if ~all(checkNumPagesAndVariants)
    hereReportColumns( );
end

dbInfo.NumPages = max(max(numPages), 1);
dbInfo.NamesAvailable = namesAvailable;

return

    function hereReportMissing( )
        thisError = [
            "DatabankPipe:MissingSeries"
            "This variable is required " + context + " "
            "but missing from the input databank: %s "
        ];
        throw(exception.Base(thisError, 'error'), allNames(~checkIncluded));
    end%


    function hereReportInvalidFrequency( )
        thisError = [ 
            "DatabankPipe:CheckInputDatabank"
            "This time series has the wrong date frequency in the input databank: %s "
        ];
        throw(exception.Base(thisError, 'error'), allNames(~checkFrequency));
    end%


    function hereReportInvalidType( )
        thisError = [ 
            "DatabankPipe:CheckInputDatabank"
            "This name is included in the input databank but is the wrong type: %s"
        ];
        throw(exception.Base(thisError, 'error'), allNames(~checkType));
    end%


    function hereReportColumns( )
        thisError = [
            "DatabankPipe:CheckInputDatabank"
            "This time series or plain numeric input has an inconsistent number of columns: %s " 
        ];
        throw(exception.Base(thisError, 'error'), allNames(~checkNumPagesAndVariants));
    end%
end%

