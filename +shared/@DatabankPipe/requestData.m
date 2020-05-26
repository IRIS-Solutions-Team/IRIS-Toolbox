function X = requestData(~, dbInfo, inputDb, dates, allNames)
% requestData  Return input data matrix for selected model names
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

dates = double(dates);
numPeriods = numel(dates);
numNames = numel(allNames);

if isequal(inputDb, "asynchronous")
    X = nan(numNames, numPeriods, 1);
    return
end

numPages = dbInfo.NumPages;
X = nan(numNames, numPeriods, numPages);

for name = dbInfo.NamesAvailable
    if isa(inputDb, 'Dictionary')
        field = retrieve(inputDb, name);
    else
        field = inputDb.(name);
    end
    if isempty(field)
        continue
    end
    if isa(field, 'NumericTimeSubscriptable') 
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
    X(name==allNames, :, :) = data;
end

end%

