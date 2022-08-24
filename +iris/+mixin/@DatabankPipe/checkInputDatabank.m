% checkInputDatabank  Check input databank for missing or non-compliant variables
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function info = checkInputDatabank( ...
    this, inputDb, dates ...
    , requiredNames, optionalNames ...
    , allowedNumeric, logNames ...
    , context ...
)

if ~isempty(requiredNames)
    requiredNames = textual.stringify(requiredNames);
else
    requiredNames = string.empty(1, 0);
end

if ~isempty(optionalNames)
    optionalNames = textual.stringify(optionalNames);
else
    optionalNames = string.empty(1, 0);
end

if ~isequal(allowedNumeric, @all)
    if ~isempty(allowedNumeric)
        allowedNumeric = textual.stringify(allowedNumeric);
    else
        allowedNumeric = string.empty(1, 0);
    end
end

if ~isempty(logNames)
    logNames = textual.stringify(logNames);
else
    logNames = string.empty(1, 0);
end

allNames = [requiredNames, optionalNames];

info = struct();
info.AllNames = allNames;
info.Dates = double(dates);
info.NumPages = NaN;
info.NamesAvailable = string.empty(1, 0);
info.OptionalNamesMissing = string.empty(1, 0);
info.LogNames = logNames;

if all(strcmpi(inputDb, 'asynchronous'))
    return
end


nv = countVariants(this);

freq = dater.getFrequency(dates);
Frequency.checkMixedFrequency(freq);
requiredFreq = freq(1);

inxOptionalNames = [false(size(requiredNames)), true(size(optionalNames))];
inxRequiredNames = [true(size(requiredNames)), false(size(optionalNames))];


checkIncluded = true(size(allNames)); % [^1]
checkFrequency = true(size(allNames)); % [^2]
checkType = true(size(allNames)); % [^3]
% [^1]: Check that all required names are available
% [^2]: Check that all time series have the correct date frequency
% [^3]: Check that there is no invalid type of input data

numAllNames = numel(allNames);

if isequal(allowedNumeric, @all)
    inxAllowedNumeric = true(1, numAllNames);
elseif isempty(allowedNumeric)
    inxAllowedNumeric = false(1, numAllNames);
else
    inxAllowedNumeric = ismember(allNames, allowedNumeric);
end

dbNames = databank.fieldNames(inputDb);
inxFound = ismember(allNames, dbNames);
inxLogInput = false(1, numAllNames);


% Find the index of names that are not in the databank, are allowed to be
% log_ names and the corresponding log_name is in the databank
logPrefix = model.Quantity.LOG_PREFIX;
if any(~inxFound) && ~isempty(logNames)
    inxAllowedLog = ismember(allNames, logNames);
    inxFoundLog = ismember(logPrefix + allNames, dbNames);
    inxLogInput = ~inxFound & inxAllowedLog & inxFoundLog;
    inxFound = inxFound | inxLogInput;
end


checkIncluded(~inxFound) = ~inxRequiredNames(~inxFound);
inxNamesAvailable = false(1, numAllNames);
numPages = nan(1, numAllNames);

for i = find(inxFound)
    name__ = allNames(i);
    if inxLogInput(i)
        name__ = logPrefix + name__;
    end

    if isstruct(inputDb)
        field__ = inputDb.(name__);
    else
        field__ = retrieve(inputDb, name__);
    end

    if isa(field__, 'Series')
        freq__ = getFrequencyAsNumeric(field__);
        checkFrequency(i) = isnan(freq__) || freq__==requiredFreq;
        inxNamesAvailable(i) = true;
        sizeField__ = sizeData(field__);
        numPages(i) = prod(sizeField__(2:end));
        continue
    end
    if (isnumeric(field__) || islogical(field__)) && inxAllowedNumeric(i) && isrow(field__)
        inxNamesAvailable(i) = true;
        sizeField__ = size(field__);
        numPages(i) = prod(sizeField__(2:end));
        continue
    end
    checkType(i) = false;
end

namesAvailable = allNames(inxNamesAvailable);

if ~all(checkIncluded)
    here_reportMissing( );
end

if ~all(checkFrequency)
    here_reportInvalidFrequency( );
end

if ~all(checkType)
    here_reportInvalidType( );
end

numPages(isnan(numPages) & inxOptionalNames) = 0;
maxNumPages = max(numPages);

checkNumPagesAndVariants ...
    = numPages==1 ...
    | numPages==0 ...
    | (nv>1 & numPages==nv) ...
    | (nv==1 & numPages==maxNumPages);

if ~all(checkNumPagesAndVariants)
    here_reportColumns( );
end

info.NumPages = max(max(numPages), 1);
info.NamesAvailable = namesAvailable;
info.OptionalNamesMissing = setdiff(optionalNames, namesAvailable);
info.NamesWithLogInputData = allNames(inxLogInput);

return

    function here_reportMissing( )
        exception.error([ 
            "DatabankPipe:MissingSeries"
            "This variable is required " + context + " "
            "but missing from the input databank: %s "
        ], allNames(~checkIncluded));
    end%


    function here_reportInvalidFrequency( )
        exception.error([ 
            "DatabankPipe:CheckInputDatabank"
            "This time series has the wrong date frequency in the input databank: %s "
        ], allNames(~checkFrequency));
    end%


    function here_reportInvalidType( )
        exception.error([ 
            "DatabankPipe:CheckInputDatabank"
            "This name is included in the input databank but is the wrong type: %s"
        ], allNames(~checkType));
    end%


    function here_reportColumns( )
        exception.error([ 
            "DatabankPipe:CheckInputDatabank"
            "This time series or plain numeric input has an inconsistent number of columns: %s " 
        ], allNames(~checkNumPagesAndVariants));
    end%
end%

