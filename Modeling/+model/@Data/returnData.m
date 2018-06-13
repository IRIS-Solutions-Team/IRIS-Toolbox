function outputDatabank = returnData(this, X, range, names)
% returnData  Create output databank from model data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TIME_SERIES_CONTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');

%--------------------------------------------------------------------------

timeSeriesTemplate = TIME_SERIES_CONTRUCTOR( );
timeSeriesTemplate.Start = range(1);
numNames = numel(names);

sizeX = size(X);
ndimsX = ndims(X);
X = X(:, :, :);

outputDatabank = struct( );

for i = 1 : numNames
    ithName = names{i};
    ithData = X(i, :, :);
    if ndimsX>3
        ithData = reshape(ithData, [1, sizeX(2:end)]);
    end
    ithData = permute(ithData, [2:ndimsX, 1]);
    outputDatabank.(ithName) = fill(timeSeriesTemplate, ithData);
end

end
