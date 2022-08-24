% returnData  Create output databank from model data
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDb = returnData(this, X, range, names)

    TIME_SERIES_TEMPLATE = Series();
    TIME_SERIES_TEMPLATE.Start = range(1);

    numNames = numel(names);

    sizeX = size(X);
    ndimsX = ndims(X);
    X = X(:, :, :);

    outputDb = struct( );
    for i = 1 : numNames
        ithName = names{i};
        ithData = X(i, :, :);
        if ndimsX>3
            ithData = reshape(ithData, [1, sizeX(2:end)]);
        end
        ithData = permute(ithData, [2:ndimsX, 1]);
        outputDb.(ithName) = fill(TIME_SERIES_TEMPLATE, ithData);
    end

end%

