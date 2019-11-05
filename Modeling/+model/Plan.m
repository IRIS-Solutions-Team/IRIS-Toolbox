classdef Plan
    properties (Abstract, Dependent)
        NamesOfEndogenousForPlan
        NamesOfExogenousForPlan
        AutoswapPairsForPlan
    end


    methods
        function plan = preparePlan(this, plan)
            plan.NamesOfEndogenous = this.NamesOfEndogenousForPlan;
            plan.NamesOfExogenous = this.NamesOfExogenousForPlan;
            baseRange = [plan.BaseStart, plan.BaseEnd];
            [plan.ExtendedStart, plan.ExtendedEnd] = getExtendedRange(this, baseRange);
            plan.AutoswapPairs = this.AutoswapPairsForPlan;
        end%
    end
end
        
