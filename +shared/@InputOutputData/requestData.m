function X = requestData(this, databankInfo, inputDatabank, dates, names)
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
    ithName = names{i};
    if ~isfield(inputDatabank, ithName) ...
       || ~isa(inputDatabank.(ithName), 'TimeSubscriptable')
        continue
    end
    ithSeries = inputDatabank.(ithName);
    % checkFrequency(ithSeries, range);
    ithData = getData(ithSeries, dates);
    ithData = ithData(:, :);
    if size(ithData, 2)==1 && numPages>1
        ithData = repmat(ithData, 1, numPages);
    end
    X(i, :, :) = permute(ithData, [3, 1, 2]);
end

end%

