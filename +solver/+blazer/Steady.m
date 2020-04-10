classdef Steady ...
    < solver.blazer.Blazer

    properties
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
        end%


        function run(this, varargin)
            run@solver.blazer.Blazer(this, varargin{:});
            if this.IsSingular
                throw( exception.Base('Steady:StructuralSingularity', 'warning') );
            end
        end%
    
    
        function [inc, idEqtns, idQties] = prepareIncidenceMatrix(this, varargin)
            PTR = @int16;
            inc = across(this.Incidence, 'Shift');
            inc = inc(this.InxEquations, this.InxEndogenous);
            idEqtns = PTR( find(this.InxEquations) ); %#ok<FNDSB>
            idQties = PTR( find(this.InxEndogenous) ); %#ok<FNDSB>
        end%


        function [names, equations] = getNamesAndEquationsToPrint(this)
            names = this.Model.Quantity.Name;
            [~, ~, equations] = parser.theparser.Equation.extractDynamicAndSteady( ...
                this.Model.Equation.Input ...
            );
        end%
    end
end

