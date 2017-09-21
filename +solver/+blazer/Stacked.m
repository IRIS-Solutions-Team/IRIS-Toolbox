classdef Stacked < solver.blazer.Blazer
    properties
        NumOfStackedTimes
    end


    properties (Constant)
        BLOCK_CONSTRUCTOR = @solver.block.Stacked
        LHS_QUANTITY_FORMAT = 'x(%g,t)'
        PREAMBLE = '@(x,t,L)'
    end
    

    methods
        function this = Stacked(numOfStackedTimes, varargin)
            this = this@solver.blazer.Blazer(varargin{:});
            this.NumOfStackedTimes = numOfStackedTimes;
        end
    end
end
