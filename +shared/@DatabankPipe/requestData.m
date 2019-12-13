function X = requestData(~, databankInfo, inputDatabank, dates, names)
% requestData  Return input data matrix for selected model names
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

dates = double(dates);
numNames = numel(names);
numPeriods = numel(dates);
numPages = databankInfo.NumOfPages;

X = nan(numNames, numPeriods, numPages);

for i = 1 : numNames
    name__ = names{i};
    if ~isfield(inputDatabank, name__)
        continue
    end
    field__ = getfield(inputDatabank, name__);
    if isempty(field__)
        continue
    end
    if isa(field__, 'NumericTimeSubscriptable') 
        %
        % Databank field is time series
        %
        data__ = getData(field__, dates);
        data__ = data__(:, :);
        if size(data__, 2)==1 && numPages>1
            data__ = repmat(data__, 1, numPages);
        end
        X(i, :, :) = permute(data__, [3, 1, 2]);
    elseif isnumeric(field__) && ~all(isnan(field__))
        % 
        % Databank field is numeric scalar for each page (allowed)
        %
        if numel(field__)==1
            X(i, :, :) = field__;
        else
            field__ = repmat(reshape(field__, 1, 1, [ ]), 1, numPeriods);
        end
    end
end

end%

