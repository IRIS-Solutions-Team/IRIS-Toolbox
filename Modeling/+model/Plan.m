classdef Plan
    properties (Abstract, Dependent)
        NamesOfEndogenousForPlan
        NamesOfExogenousForPlan
        AutoswapPairsForPlan
    end


    methods
        function plan = preparePlan(this, plan, baseRange)
            plan.NamesOfEndogenous = this.NamesOfEndogenousForPlan;
            plan.NamesOfExogenous = this.NamesOfExogenousForPlan;
            [plan.ExtendedStart, plan.ExtendedEnd] = getExtendedRange(this, baseRange);
            plan.AutoswapPairs = this.AutoswapPairsForPlan;
        end%
    end
end
        
