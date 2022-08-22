% stdize  Standardize numeric data
%

function [x, meanX, stdX] = stdize(x, varargin)

    persistent inputParser
    if isempty(inputParser)
        inputParser = extend.InputParser();
        inputParser.addRequired('inputData', @isnumeric);
        inputParser.addOptional('flag', 0, @(x) isequal(x, 0) || isequal(x, 1));
        inputParser.addOptional('dim', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
    end
    inputParser.parse(x, varargin{:});
    flag = inputParser.Results.flag;
    dim = inputParser.Results.dim;

    [x, redimStruct] = series.redim(x, dim);

    % Compute, remove and store mean
    meanX = mean(x, 1, 'OmitNaN');
    x = bsxfun(@minus, x, meanX);

    % Compute, remove and store std deviations
    stdX = std(x, flag, 1, 'OmitNaN');
    x = bsxfun(@rdivide, x, stdX);

    x = series.redim(x, dim, redimStruct);
    meanX = series.redim(meanX, dim, redimStruct);
    stdX = series.redim(stdX, dim, redimStruct);

end%

