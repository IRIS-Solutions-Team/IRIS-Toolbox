classdef Selective ...
    < solver.blazer.Blazer

    properties
        Terminal = "firstOrder"
        StartIterationsFrom = "firstOrder"
    end


    properties (Constant)
        BLOCK_CONSTRUCTOR
        LHS_QUANTITY_FORMAT
        TYPES_ALLOWED_CHANGE_LOG_STATUS
    end


    methods
        function this = Selective(varargin)
            this = this@solver.blazer.Blazer(0);
            this.Blocks = { solver.block.Selective };
        end%

        function varargout = prepareIncidenceMatrix(varargin)
        end%

        function setFrame(varargin)
        end%

        function run(varargin)
        end%
    end
end

