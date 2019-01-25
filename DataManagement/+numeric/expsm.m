function smooth = expsm(x, beta, varargin)
% expsm  Apply exponential smoothing to numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('numeric.expsm');
    inputParser.addRequired('InputData', @isnumeric);
    inputParser.addRequired('Beta', @(x) isnumeric(x) && isscalar(x) && x>=0 && x<=1);
    inputParser.addOptional('Init', NaN, @(x) isnumeric(x) && isscalar(x));
end
inputParser.parse(x, beta, varargin{:});
init = inputParser.Results.Init;

%--------------------------------------------------------------------------

if beta<0 || beta>1
    sse = Inf;
    return
end

sizeX = size(x);
ndimsX = ndims(x);
x = x(:, :);
numColumns = size(x, 2);

smooth = nan(size(x));
numPeriods0 = NaN;
isInit = ~isnan(init);
for i = 1 : numColumns
    ithX = x(:, i);    
    ixNaNData = isnan(ithX);
    first = find(~ixNaNData, 1);
    last = find(~ixNaNData, 1, 'last');
    ithX = ithX(first:last);
    if isInit
        ithX = [init; ithX]; %#ok<AGROW>
    end
    numPeriods = size(ithX, 1);
    if numPeriods~=numPeriods0
        w = TimeSubscriptable.getExpSmoothMatrix(beta, numPeriods);
    end
    ithX = w*ithX;
    if isInit
        ithX = ithX(2:end);
    end
    smooth(first:last, i) = ithX;
    numPeriods0 = numPeriods;
end

if ndimsX>2
    smooth = reshape(smooth, sizeX);
end

end
