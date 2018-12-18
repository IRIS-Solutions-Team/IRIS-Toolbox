classdef Plan
    properties (Abstract, Dependent)
        NamesOfEndogenousInPlan
        NamesOfExogenousInPlan
    end


    methods
        function plan = preparePlan(this, plan, baseRange)
            plan.NamesOfEndogenous = this.NamesOfEndogenousInPlan;
            plan.NamesOfExogenous = this.NamesOfExogenousInPlan;
            [plan.ExtendedStart, plan.ExtendedEnd] = getExtendedRange(this, baseRange);
        end%
    end
end
        
