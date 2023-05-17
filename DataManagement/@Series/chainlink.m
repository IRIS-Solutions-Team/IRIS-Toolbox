% >=R2019b
%(
function [aggregateLevel, aggregateRate, info] = chainlink(levels, weights, opt)

arguments
    levels (:, :) Series
    weights (:, :) Series

    opt.Range = Inf
    opt.RebaseDates = []
    opt.NormalizeWeights (1, 1) logical = true
    opt.GrowFrom = []
    opt.DecumulateFunc (1, 1) string {mustBeMember(opt.DecumulateFunc, ["diff", "difflog", "roc", "pct"])} = "roc"
    opt.WhenMissing (1, 1) string {mustBeMember(opt.WhenMissing, ["error", "warning", "silent"])} = "error"
end
%)
% >=R2019b


% <=R2019a
%{
function [aggregateLevel, aggregateRate, info] = chainlink(levels, weights, varargin)

persistent ip
if isempty(ip)
ip = inputParser(); 
    addParameter(ip, "Range", Inf);
    addParameter(ip, "RebaseDates", []);
    addParameter(ip, "NormalizeWeights", true);
    addParameter(ip, "WhenMissing", "error");
    addParameter(ip, "DecumulateFunc", "roc");
end
parse(ip, varargin{:});
opt = ip.Results;
%}
% <=R2019a


    if ~isequal(opt.Range, Inf)
        levels = clip(levels, opt.Range);
        weights = clip(weights, opt.Range);
        here_checkMissing();
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
    delevelFunc = str2func(opt.DecumulateFunc);
    rates = delevelFunc(levels, "EoPY");


    %
    % Calculate aggregate rates of change
    %
    aggregateRate = sum(rates * weights, 2);


    %
    % Calculate aggregate level
    %
    rateRange = getRange(aggregateRate);
    if isempty(opt.GrowFrom)
        growRange = rateRange(1)-1 : rateRange(end);
        growFrom = Series(growRange, 1);
    else
        growFrom = opt.GrowFrom;
    end 

    % Recumulate the aggregate rate of change
    aggregateLevel = grow( ...
        growFrom, opt.DecumulateFunc, aggregateRate, rateRange ...
        , "shift", "EoPY" ...
    );

    if ~isempty(opt.RebaseDates)
        aggregateLevel = 100 * normalize(aggregateLevel, opt.RebaseDates);
    end

    if nargout>=3
        info = struct();
        info.Rates = rates;
        info.Weights = weights;
    end

return

    function here_checkMissing()
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
                "Series"
                "Some level input series into Series/chainlink have missing observations."
            ]);
        end
        if any(inxWeightMissing)
            func([
                "Series"
                "Some weight input series into Series/chainlink have missing observations."
            ]);
        end
        %)
    end%

end%
