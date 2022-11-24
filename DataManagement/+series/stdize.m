% stdize  Standardize numeric data
%

function [x, meanX, stdX] = stdize(x, varargin)

    persistent ip
    if isempty(ip)
        ip = extend.InputParser();
        addRequired(ip, 'inputData', @isnumeric);
        addOptional(ip, 'flag', 0, @(x) isequal(x, 0) || isequal(x, 1));
        addOptional(ip, 'dim', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
    end
    parse(ip, x, varargin{:});
    flag = ip.Results.flag;
    dim = ip.Results.dim;

    [x, redimStruct] = series.redim(x, dim);

    % Compute, remove and store mean
    meanX = mean(x, 1, 'omitNaN');
    x = bsxfun(@minus, x, meanX);

    % Compute, remove and store std deviations
    stdX = std(x, flag, 1, 'omitNaN');
    x = bsxfun(@rdivide, x, stdX);

    x = series.redim(x, dim, redimStruct);
    meanX = series.redim(meanX, dim, redimStruct);
    stdX = series.redim(stdX, dim, redimStruct);

end%

