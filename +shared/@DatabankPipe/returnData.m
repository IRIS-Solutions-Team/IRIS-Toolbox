function outputDatabank = returnData(this, X, range, names)
% returnData  Create output databank from model data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TIME_SERIES_TEMPLATE = TIME_SERIES_CONSTRUCTOR( );
TIME_SERIES_TEMPLATE.Start = range(1);

%--------------------------------------------------------------------------

numOfNames = numel(names);

sizeOfX = size(X);
ndimsOfX = ndims(X);
X = X(:, :, :);

outputDatabank = struct( );
for i = 1 : numOfNames
    ithName = names{i};
    ithData = X(i, :, :);
    if ndimsOfX>3
        ithData = reshape(ithData, [1, sizeOfX(2:end)]);
    end
    ithData = permute(ithData, [2:ndimsOfX, 1]);
    outputDatabank.(ithName) = fill(TIME_SERIES_TEMPLATE, ithData);
end

end%

