function this = randomlyGrowing(range, params, varargin)

arguments
    range {mustBeNonempty, validate.mustBeProperRange(range)}
    params (1, 2) double = [0, 1]
end

arguments (Repeating)
    varargin
end

numPeriods = dater.rangeLength(range);
data = params(1) + randn(numPeriods, 1) * params(2);
data = exp(cumsum(data, 1));
this = Series(range(1), data, varargin{:});

end%

