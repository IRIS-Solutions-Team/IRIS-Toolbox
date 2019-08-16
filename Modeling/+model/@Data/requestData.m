function X = requestData(this, databankInfo, inputDatabank, range, names)
% requestData  Return input data matrix for selected model names
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

range = double(range);
numOfNames = numel(names);
numOfPeriods = numel(range);
numOfPages = databankInfo.NumOfPages;

X = nan(numOfNames, numOfPeriods, numOfPages);

for i = 1 : numOfNames
    ithName = names{i};
    if ~isfield(inputDatabank, ithName) ...
       || ~isa(inputDatabank.(ithName), 'TimeSubscriptable')
        continue
    end
    ithSeries = inputDatabank.(ithName);
    % checkFrequency(ithSeries, range);
    ithData = getData(ithSeries, range);
    ithData = ithData(:, :);
    if size(ithData, 2)==1 && numOfPages>1
        ithData = repmat(ithData, 1, numOfPages);
    end
    X(i, :, :) = permute(ithData, [3, 1, 2]);
end

end%
