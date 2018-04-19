function [trend, rem] = ellone(this, order, lambda, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('TimeSubscriptable.ellone');
    inputParser.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable') && isnumeric(x.Data));
    inputParser.addRequired('Order', @(x) isequal(x, 1) || isequal(x, 2));
    inputParser.addRequired('Lambda', @(x) isnumeric(x) && isscalar(x) && x>0);
    inputParser.addOptional('StartDate', -Inf, @(x) DateWrapper.validateDateInput(x) && isscalar(x));
    inputParser.addOptional('EndDate', Inf, @(x) DateWrapper.validateDateInput(x) && isscalar(x));
end
inputParser.parse(this, order, lambda, varargin{:});
startDate = inputParser.Results.StartDate;
endDate = inputParser.Results.EndDate;

%--------------------------------------------------------------------------

[data, range] = getDataFromTo(this, round(startDate), round(endDate));
numPeriods = size(data, 1);

d = eye(numPeriods-order, numPeriods);
D = d;
if order==1
    D(:, 2:end) = D(:, 2:end) - d(:, 1:end-1);
else
    D(:, 2:end) = D(:, 2:end) - 2*d(:, 1:end-1); 
    D(:, 3:end) = D(:, 3:end) + d(:, 1:end-2);
end

H = D*D';
f = -D*data;
bound = repmat(lambda, numPeriods-order, 1);
nu = quadprog(H, f, [ ], [ ], [ ], [ ], -bound, bound);
trendData = data - D'*nu;

newStart = getFirst(range);
trend = fill(this, trendData, newStart);
rem = fill(this, data - trendData, newStart);

end
