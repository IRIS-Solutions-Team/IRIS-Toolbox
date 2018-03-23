classdef Stacked < solver.blazer.Blazer
    properties (Constant)
        BLOCK_CONSTRUCTOR = @solver.block.Stacked
        LHS_QUANTITY_FORMAT = 'x(%g,t)'
        PREAMBLE = '@(x,t,L)'
    end
    

    methods
        function this = Stacked(varargin)
            this = this@solver.blazer.Blazer(varargin{:});
        end
    end
end
