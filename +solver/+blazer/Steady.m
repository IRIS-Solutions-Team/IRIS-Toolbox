classdef Steady < solver.blazer.Blazer
    properties
        IxZero % Index of level and growth quantities set to zero
        IdToFix = struct('Level', [ ], 'Growth', [ ]) % Positions of level and growth quantities fixed by user
        IdToExclude = struct('Level', [ ], 'Growth', [ ]) % Positions of level and growth quantities excluded from optimization
        Reuse % Use values from previous variant as initial condition
        Warning % Throw warnings
    end


    properties (Constant)
        BLOCK_CONSTRUCTOR = @solver.block.Steady
        LHS_QUANTITY_FORMAT = 'x(%g,t'
        PREAMBLE = '@(x,t)'
    end
    
    
    methods
        function this = Steady(varargin)
            this = this@solver.blazer.Blazer(varargin{:});
        end
    end
end
