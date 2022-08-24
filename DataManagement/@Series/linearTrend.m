% linearTrend  Create time series with linear trend
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function this = linearTrend(range, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    ip.KeepUnmatched = true;
    ip.addRequired('range', @validate.properRange);
    ip.addParameter('Step', 1, @validate.numericScalar);
    ip.addParameter('StartValue', 0, @(x) isnumeric(x) && size(x, 1)==1);
end
ip.parse(range, varargin{:});
opt = ip.Results;

    step = opt.Step;
    startValue = opt.StartValue;

    range = double(range);
    startDate = range(1);

    numPeriods = round(range(end) - range(1) + 1);
    zeroStart = zeros(size(step));
    step = repmat(step, numPeriods-1, 1);
    data = cumsum([zeroStart; step], 1);
    if any(startValue(:))~=0
        startValue = repmat(startValue, numPeriods, 1);
        data = data + startValue;
    end
    this = Series(startDate, data, ip.UnmatchedInCell{:});

end%

