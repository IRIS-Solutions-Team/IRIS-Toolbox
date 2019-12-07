function X = requestData(~, databankInfo, inputDatabank, dates, names)
% requestData  Return input data matrix for selected model names
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

dates = double(dates);
numNames = numel(names);
numPeriods = numel(dates);
numPages = databankInfo.NumOfPages;

X = nan(numNames, numPeriods, numPages);

for i = 1 : numNames
    name__ = names{i};
    if ~isfield(inputDatabank, name__) ...
       || ~isa(inputDatabank.(name__), 'TimeSubscriptable')
        continue
    end
    series__ = inputDatabank.(name__);
    % checkFrequency(series__, range);
    data__ = getData(series__, dates);
    data__ = data__(:, :);
    if size(data__, 2)==1 && numPages>1
        data__ = repmat(data__, 1, numPages);
    end
    X(i, :, :) = permute(data__, [3, 1, 2]);
end

end%

