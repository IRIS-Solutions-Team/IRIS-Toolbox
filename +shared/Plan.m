classdef Plan
    methods (Abstract, Access=protected)
        getEndogenousForPlan
        getExogenousForPlan
        getAutoswapsForPlan
        getSigmasForPlan
    end


    methods
        function plan = preparePlan(this, plan)
            plan.NamesOfEndogenous = getEndogenousForPlan(this);
            plan.NamesOfExogenous = getExogenousForPlan(this);
            baseRange = [plan.BaseStart, plan.BaseEnd];
            [plan.ExtendedStart, plan.ExtendedEnd] = getExtendedRange(this, baseRange);
            plan.AutoswapPairs = getAutoswapPairsForPlan(this);
            sigmas = getSigmasForPlan(this);
            numVariants = size(sigmas, 3);
            numExtendedPeriods = this.NumOfExtendedPeriods;
            plan.SigmasOfExogenous = nan(plan.NumOfExogenous, numExtendedPeriods, numVariants);
            plan.SigmasOfExogenous = repmat(sigmas, 1, 1, numExtendedPeriods);
        end%
    end
end

