
function plan = preparePlan(this, plan)

    plan.NamesOfEndogenous = getEndogenousForPlan(this);
    plan.NamesOfExogenous = getExogenousForPlan(this);
    [plan.ExtendedStart, plan.ExtendedEnd, ~, ~, inxBaseRange] = getExtendedRange(this, [plan.BaseStart, plan.BaseEnd]);

    plan.AutoswapPairs = getAutoswapsForPlan(this);
    plan.SlackPairs = getSlackPairsForPlan(this);

    sigmas = getSigmasForPlan(this);
    numVariants = size(sigmas, 3);
    numExtPeriods = plan.NumExtdPeriods;
    plan.DefaultSigmasExogenous = sigmas;
    sigmas = repmat(sigmas, 1, numExtPeriods, 1);
    sigmas(:, ~inxBaseRange, :) = NaN;
    plan.SigmasExogenous = sigmas;

end%

