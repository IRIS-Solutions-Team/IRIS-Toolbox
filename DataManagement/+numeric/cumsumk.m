function x = cumsumk(x, k, varargin)
% cumsumk  Cumulative sum over k periods
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('numeric.cumsumk');
    inputParser.addRequired('InputData', @isnumeric);
    inputParser.addRequired('K', @(x) isnumeric(x) && isscalar(x) && x==round(x));
    inputParser.addOptional('Rho', 1, @(x) isnumeric(x) && isscalar(x));
    inputParser.addOptional('NaNInit', 0, @isnumeric);
end
inputParser.parse(x, k, varargin{:});
rho = inputParser.Results.Rho;
nanInit = inputParser.Results.NaNInit;

%--------------------------------------------------------------------------

sizeX = size(x);
ndimsX = ndims(x);
if ndimsX>2
    x = x(:, :);
end

numOfPeriods = sizeX(1);
for i = 1 : size(x, 2)
    indexOfNaN = isnan(x(:, i));
    x(indexOfNaN, i) = nanInit;
    if k<0
        first = find(~isnan(x(:, i)), 1);
        if isempty(first)
            continue
        end
        
        for t = (first-k) : numOfPeriods
            x(t, i) = rho*x(t+k, i) + x(t, i);
        end
    elseif k>0
        last = find(~isnan(x(:, i)), 1, 'last');
        if isempty(last)
            continue
        end
        for t = (last-k) : -1 : 1
            x(t, i) = rho*x(t+k, i) + x(t, i);
        end        
    end
end

% Remove presample or postsample
if k<0
    x = x(1-k:end, :);
elseif k>0
    x = x(1:end-k, :);
end

if ndimsX>2
    sizeX(1) = sizeX(1) - abs(k);
    x = reshape(x, sizeX);
end

end
