function X = requestData(this, check, inputDatabank, range, names)
% requestData  Return input data matrix for selected model names
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

numOfNames = numel(names);
numOfPeriods = length(range);
numOfDataSets = check.NumDataSets;

X = nan(numOfNames, numOfPeriods, numOfDataSets);

for i = 1 : numOfNames
    ithName = names{i};
    if ~isfield(inputDatabank, ithName) ...
        || ~isa(inputDatabank.(ithName), 'TimeSubscriptable')
        continue
    end
    ithSeries = inputDatabank.(ithName);
    checkFrequencyOrInf(ithSeries, range);
    ithData = getData(ithSeries, range);
    ithData = ithData(:, :);
    if size(ithData, 2)==1 && numOfDataSets>1
        ithData = ithData(:, ones(1, numOfDataSets));
    end
    X(i, :, :) = permute(ithData, [3, 1, 2]);
end

end%
