% >=R2019b
%{
function [aggregateLevel, aggregateRate, info] = chainlink(levels, weights, opt)

arguments
    levels Series
    weights Series

    opt.Range = Inf
    opt.RebaseDates = []
    opt.NormalizeWeights (1, 1) logical = true
    opt.WhenMissing (1, 1) string {mustBeMember(opt.WhenMissing, ["error", "warning", "silent"])} = "error"
end
%}
% >=R2019b


% <=R2019a
%(
function [aggregateLevel, aggregateRate, info] = chainlink(levels, weights, varargin)

persistent ip
if isempty(ip)
ip = inputParser(); 
    addParameter(ip, "Range", Inf);
    addParameter(ip, "RebaseDates", []);
    addParameter(ip, "NormalizeWeights", true);
    addParameter(ip, "WhenMissing", "error");
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


if ~isequal(opt.Range, Inf)
    levels = clip(levels, opt.Range);
    weights = clip(weights, opt.Range);
    hereCheckMissing();
end


%
% Normalize weights
%
if opt.NormalizeWeights
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

if ~isempty(opt.RebaseDates)
    aggregateLevel = 100 * normalize(aggregateLevel, opt.RebaseDates);
end

if nargout>=3
    info = struct();
    info.Rates = rates;
    info.Weights = weights;
end

return

    function hereCheckMissing()
        %(
        if opt.WhenMissing=="error"
            func = @exception.error;
        elseif opt.WhenMissing=="warning"
            func = @exception.warning;
        else
            return
        end
        levelsData = getDataFromTo(levels, opt.Range);
        weightsData = getDataFromTo(weights, opt.Range);
        inxLevelMissing = any(~isfinite(levelsData(:)));
        inxWeightMissing = any(~isfinite(weightsData(:)));
        if any(inxLevelMissing)
            func([
                "Series:MissingInput"
                "Some level input series into Series/chainlink have missing observations."
            ]);
        end
        if any(inxWeightMissing)
            func([
                "Series:MissingInput"
                "Some weight input series into Series/chainlink have missing observations."
            ]);
        end
        %)
    end%

end%
