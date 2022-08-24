% requestData  Retrieve input data matrix for selected model names
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function X = requestData(~, dbInfo, inputDb, namesInRows, dates)

numPeriods = numel(dates);
numNames = numel(namesInRows);

if all(strcmpi(inputDb, 'asynchronous'))
    X = nan(numNames, numPeriods, 1);
    return
end

numPages = dbInfo.NumPages;
X = nan(numNames, numPeriods, numPages);

logPrefix = model.Quantity.LOG_PREFIX;;
inxLogInput = ismember(namesInRows, dbInfo.NamesWithLogInputData);
hasAnyNamesWithLogInputData = ~isempty(dbInfo.NamesWithLogInputData);

for name = dbInfo.NamesAvailable

    if ismissing(name)
        continue
    end

    inxName = name==namesInRows;
    if ~any(inxName)
        continue
    end

    dbName = name;
    if hasAnyNamesWithLogInputData && any(dbName==dbInfo.NamesWithLogInputData)
        dbName = logPrefix + dbName;
    end

    if isstruct(inputDb)
        field = inputDb.(dbName);
    else
        field = retrieve(inputDb, dbName);
    end

    if isempty(field)
        continue
    end
    if isa(field, 'Series') 
        %
        % Databank field is a time series
        %
        data = getData(field, dates);
        data = data(:, :);
        if size(data, 2)==1 && numPages>1
            data = repmat(data, 1, numPages);
        end
        data = permute(data, [3, 1, 2]);
    else
        % 
        % Databank field is a numeric or logical scalar for each page
        %
        if isscalar(field)
            data = field;
        else
            data = repmat(reshape(field, 1, 1, [ ]), 1, numPeriods, 1);
        end
    end
    X(name==namesInRows, :, :) = data;
end

end%

