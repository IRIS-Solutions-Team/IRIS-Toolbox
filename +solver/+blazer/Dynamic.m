classdef Dynamic < solver.blazer.Blazer
    properties (Constant)
        BLOCK_CONSTRUCTOR = @solver.block.Dynamic
        LHS_QUANTITY_FORMAT = 'x(%g,t)'
        PREAMBLE = '@(x,t,L)'
    end
    
    
    methods
        function this = Dynamic(varargin)
            this = this@solver.blazer.Blazer(varargin{:});
        end
    end
end
