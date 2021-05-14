function [aggregateLevel, aggregateRate, info] = chainlink(levels, weights, options)

arguments
    levels Series
    weights Series

    options.Range = Inf
    options.RebaseDates = []
    options.NormalizeWeights (1, 1) logical = true
end


if ~isequal(options.Range, Inf)
    levels = clip(levels, options.Range);
    weights = clip(weights, options.Range);
end


%
% Normalize weights
%
if options.NormalizeWeights
    weights = weights / sum(weights, 2);
end


%
% Calculate rates of change relative to last period of previous year
%
rates = roc(levels, "EoPY");


%
% Calculate aggregate rates of change
%
aggregateRate = sum(rates * weights, 2);


%
% Calculate aggregate level
%
rateRange = getRangeAsNumeric(aggregateRate);
growRange = dater.colon(dater.plus(rateRange(1), -1), rateRange(end));
aggregateLevel = Series(growRange, 1);
aggregateLevel = grow(aggregateLevel, "roc", aggregateRate, getRange(aggregateRate), "EoPY");

if ~isempty(options.RebaseDates)
    aggregateLevel = 100 * normalize(aggregateLevel, options.RebaseDates);
end

if nargout>=3
    info = struct();
    info.Rates = rates;
    info.Weights = weights;
end

end%

