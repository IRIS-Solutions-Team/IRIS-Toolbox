classdef FirstOrder ...
    < solver.blazer.Blazer

    properties
        Terminal = "none"
        StartIterationsFrom = "firstOrder"
    end


    properties (Constant)
        BLOCK_CONSTRUCTOR
        LHS_QUANTITY_FORMAT
        TYPES_ALLOWED_CHANGE_LOG_STATUS
    end


    methods
        function this = FirstOrder(varargin)
            this = this@solver.blazer.Blazer(0);
            this.Blocks = cell.empty(1, 0);
        end%

        function varargout = prepareIncidenceMatrix(varargin)
        end%

        function setFrame(varargin)
        end%

        function run(varargin)
        end%
    end
end

