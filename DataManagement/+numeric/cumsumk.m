function x = cumsumk(x, k, varargin)
% cumsumk  Cumulative sum over k periods
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('numeric.cumsumk');
    inputParser.addRequired('InputData', @isnumeric);
    inputParser.addRequired('K', @(x) isnumeric(x) && isscalar(x) && x==round(x));
    inputParser.addOptional('Rho', 1, @(x) isnumeric(x) && isscalar(x));
end
inputParser.parse(x, k, varargin{:});
rho = inputParser.Results.Rho;

%--------------------------------------------------------------------------

sizeX = size(x);
ndimsX = ndims(x);
if ndimsX>2
    x = x(:, :);
end

numPeriods = sizeX(1);
for i = 1 : size(x, 2)
    if k<0
        first = find(~isnan(x(:, i)), 1);
        if isempty(first)
            continue
        end
        
        for t = (first-k) : numPeriods
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

if ndimsX>2
    x = reshape(x, sizeX);
end

end
