function [trend, rem] = ellpea(this, lambda, pea, diffOrder, varargin)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('TimeSubscriptable.ellpea');
    INPUT_PARSER.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable') && isnumeric(x.Data));
    INPUT_PARSER.addRequired('Lambda', @(x) isnumeric(x) && isscalar(x) && x>0);
    INPUT_PARSER.addRequired('Pea', @(x) isnumeric(x) && any(numel(x)==[1,2]) && all(x>=1));
    INPUT_PARSER.addRequired('DiffOrder', @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
    INPUT_PARSER.addOptional('Range', Inf, @(x) isequal(x, Inf) || isa(x, 'DateWrapper'));
end
INPUT_PARSER.parse(this, lambda, pea, diffOrder, varargin{:});
range = INPUT_PARSER.Results.Range;

%--------------------------------------------------------------------------

[data, range] = getData(this, range);

p1 = pea(1);
p2 = pea(end);
objective = @(x) sum(abs(data-x).^p1) + lambda*sum(abs(diff(x, diffOrder)).^p2);

oo = optimoptions('fminunc', 'MaxFunEvals', 100000, 'MaxIter', 100000, ...
    'OptimalityTolerance', 1e-10, 'StepTolerance', 1e-10);
trendData = fminunc(objective, data, oo);

trend = fill(this, trendData);
rem = fill(this, data - trendData);

end
