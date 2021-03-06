classdef Steady ...
    < solver.blazer.Blazer

    properties
        Reuse % Use values from previous variant as initial condition
        Warning % Throw warnings
    end


    properties (Constant)
        BLOCK_CONSTRUCTOR = @solver.block.Steady
        LHS_QUANTITY_FORMAT = 'x(%g,t'
        TYPES_ALLOWED_CHANGE_LOG_STATUS = { 1, 2, 4, 5 }
    end
    
    
    methods
        function this = Steady(varargin)
            this = this@solver.blazer.Blazer(varargin{:});
        end%


        function run(this)
            run@solver.blazer.Blazer(this);

            if this.IsSingular
                if ~isempty(this.SuspectEquations)
                    report = string(this.Model.Equation.Input(this.SuspectEquations));
                    exception.error([
                        "Blazer:StructuralSingularity"
                        "System of steady equations is structurally singular: Suspect %s"
                    ], report);
                else
                    exception.warning([
                        "Blazer:StructuralSingularity"
                        "System of steady equations is structurally singular: no obvious suspect."
                    ]);
                end
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


    methods (Static)
        varargout = forModel(varargin)
    end
end

