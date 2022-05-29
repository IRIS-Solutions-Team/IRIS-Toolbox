% linearTrend  Create time series with linear trend
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function this = linearTrend(constructor, range, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('NumericTimeSubscriptable.linearTrend');
    inputParser.addRequired('range', @validate.properRange);
    inputParser.addOptional('step', 1, @validate.numericScalar);
    inputParser.addOptional('startValue', 0, @(x) isnumeric(x) && size(x, 1)==1);
end
inputParser.parse(range, varargin{:});
step = inputParser.Results.step;
startValue = inputParser.Results.startValue;
range = double(range);
startDate = range(1);

%--------------------------------------------------------------------------

numPeriods = round(range(end) - range(1) + 1);
zeroStart = zeros(size(step));
step = repmat(step, numPeriods-1, 1);
data = cumsum([zeroStart; step], 1);
if any(startValue(:))~=0
    startValue = repmat(startValue, numPeriods, 1);
    data = data + startValue;
end
this = constructor(startDate, data);

end%

