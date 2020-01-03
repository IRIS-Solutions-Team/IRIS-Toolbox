function [x, meanX, stdX] = stdize(x, varargin)
% stdize  Standardize numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('numeric.stdize');
    inputParser.addRequired('inputData', @isnumeric);
    inputParser.addOptional('flag', 0, @(x) isequal(x, 0) || isequal(x, 1));
    inputParser.addOptional('dim', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
end
inputParser.parse(x, varargin{:});
flag = inputParser.Results.flag;
dim = inputParser.Results.dim;

%--------------------------------------------------------------------------

[x, redimStruct] = numeric.redim(x, dim);

% Compute, remove and store mean
meanX = mean(x, 1, 'OmitNaN');
x = bsxfun(@minus, x, meanX);

% Compute, remove and store std deviations
stdX = std(x, flag, 1, 'OmitNaN');
x = bsxfun(@rdivide, x, stdX);

x = numeric.redim(x, dim, redimStruct);
meanX = numeric.redim(meanX, dim, redimStruct);
stdX = numeric.redim(stdX, dim, redimStruct);

end%

