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


    properties (Dependent)
        InxOfZero
    end


    methods % Dependent
        %(
        function value = get.InxOfZero(this)
            value = this.IxZero;
        end%
        %)
    end
end

