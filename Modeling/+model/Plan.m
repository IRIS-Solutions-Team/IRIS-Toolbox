classdef Plan
    methods (Abstract, Access=protected)
        getEndogenousForPlan
        getExogenousForPlan
        getAutoswapPairsForPlan
    end


    methods
        function plan = preparePlan(this, plan)
            plan.NamesOfEndogenous = getEndogenousForPlan(this);
            plan.NamesOfExogenous = getExogenousForPlan(this);
            baseRange = [plan.BaseStart, plan.BaseEnd];
            [plan.ExtendedStart, plan.ExtendedEnd] = getExtendedRange(this, baseRange);
            plan.AutoswapPairs = getAutoswapPairsForPlan(this);
        end%
    end
end
        
