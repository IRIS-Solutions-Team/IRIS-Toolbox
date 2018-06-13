function X = requestData(this, check, inputDatabank, range, names)
% requestData  Return input data matrix for selected model names
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

numNames = numel(names);
numPeriods = length(range);
numDataSets = check.NumDataSets;

X = nan(numNames, numPeriods, numDataSets);

for i = 1 : numNames
    ithName = names{i};
    if ~isfield(inputDatabank, ithName) ...
        || ~isa(inputDatabank.(ithName), 'TimeSubscriptable')
        continue
    end
    ithData = getData(inputDatabank.(ithName), range);
    ithData = ithData(:, :);
    if size(ithData, 2)==1 && numDataSets>1
        ithData = ithData(:, ones(1, numDataSets));
    end
    X(i, :, :) = permute(ithData, [3, 1, 2]);
end

end
