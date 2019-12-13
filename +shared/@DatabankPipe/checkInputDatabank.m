function databankInfo = checkInputDatabank( ...
    this, inputDatabank, range, ...
    requiredNames, optionalNames, context, ...
    namesAllowedScalar ...
)
% checkInputDatabank  Check input databank for missing or non-compliant variables
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

if nargin<6
    context = "";
end

if nargin<7
    namesAllowedScalar = string.empty(1, 0);
elseif ~isequal(namesAllowedScalar, @all)
    namesAllowedScalar = string(namesAllowedScalar);
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
    name__ = string(allNames{i});
    allowedScalar__ = isequal(namesAllowedScalar, @all) || any(name__==namesAllowedScalar);
    try
        field__ = getfield(inputDatabank, name__);
    catch
        field__ = missing( );
    end
    if isa(field__, 'TimeSubscriptable')
        if ~isempty(field__)
            freq__ = getFrequencyAsNumeric(field__);
            checkFrequency(i) = isnan(freq__) || freq__==requiredFreq;
        end
        continue
    end
    if isnumeric(field__) && allowedScalar__ && isrow(field__)
        continue
    end
    checkIncluded(i) = ~inxRequiredNames(i);
end

if ~all(checkIncluded)
    hereReportMissing( );
end

if ~all(checkFrequency)
    hereReportFrequency( );
end

numPages = databank.backend.countColumns(inputDatabank, allNames);
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

databankInfo = struct( );
databankInfo.NumOfPages = max(max(numPages), 1);

return

    function hereReportMissing( )
        thisError = [
            "DatabankPipe:MissingSeries"
            "This variable is required " + context + " "
            "but missing from the input databank: %s "
        ];
        throw(exception.Base(thisError, 'error'), allNames{~checkIncluded});
    end%


    function hereReportFrequency( )
        thisError = [ 
            "DatabankPipe:CheckInputDatabank"
            "This time series has the wrong date frequency in the input databank: %s "
        ];
        throw(exception.Base(thisError, 'error'), allNames{~checkFrequency});
    end%


    function hereReportColumns( )
        thisError = [
            "DatabankPipe:CheckInputDatabank"
            "This time series or numeric input has an inconsistent number of columns: %s " 
        ];
        throw(exception.Base(thisError, 'error'), allNames{~checkNumPagesAndVariants});
    end%
end%

