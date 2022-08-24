% toDoubleArrayNoFrills  Retrieve data from time series into numeric array with no checks
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputArray = toDoubleArrayNoFrills(inputDb, names, dates, columns, apply)

try, columns;
    catch, columns = 1; end

try, apply;
    catch, apply = [ ]; end

%--------------------------------------------------------------------------

names = string(names);
dates = double(dates);
numNames = numel(names); 
numDates = numel(dates);
numPages = numel(columns);
outputArray = nan(numDates, numNames, numPages);
if isempty(outputArray)
    return
end

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

    if ~isa(field__, 'Series')
        continue
    end

    sizeData__ = size(field__);
    numColumns__ = prod(sizeData__(2:end));
    value__ = [ ];
    if numColumns__==1
        value__ = getDataNoFrills(field__, dates, 1);
        if numPages>1
            value__ = repmat(value__, 1, 1, numPages);
        end
    elseif numColumns__>1
        value__ = getDataNoFrills(field__, dates, columns);
    end
    if ~isempty(value__) 
        if ~isempty(apply)
            value__ = apply(value__);
        end
        outputArray(:, i, :) = value__;
    end
end

end%

