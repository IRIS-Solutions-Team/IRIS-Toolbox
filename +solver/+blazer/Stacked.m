classdef Stacked ...
    < solver.blazer.Blazer

    properties
        ColumnsToRun = double.empty(1, 0)
    end


    properties (Constant)
        BLOCK_CONSTRUCTOR = @solver.block.Stacked
        LHS_QUANTITY_FORMAT = 'x(%g,t)'
        PREAMBLE = '@(x,t,L)'
    end
    

    methods
        function this = Stacked(varargin)
            this = this@solver.blazer.Blazer(varargin{:});
        end%


        function [inc, idEqtns, idQties] = prepareIncidenceMatrix(this, plan)
            PTR = @int16;
            inc = across(this.Incidence, 'Shift');
            inc = inc(this.InxEquations, this.InxEndogenous);
            idEqtns = PTR( find(this.InxEquations) ); %#ok<FNDSB>
            idQties = PTR( find(this.InxEndogenous) ); %#ok<FNDSB>
        end%
    end
end
