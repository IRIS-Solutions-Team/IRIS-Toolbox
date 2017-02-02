classdef Steady < solver.blazer.Blazer
    properties
        IxZero % Index of level and growth quantities set to zero.
        PosFix % Positions of level and growth quantities fixed by user.
        Reuse % Use values from previous variant as initial condition.
        Warning % Throw warnings.
    end
    
    
    
    
    methods
        function this = Steady(varargin)
            this = this@solver.blazer.Blazer(varargin{:});
        end
    end
end
