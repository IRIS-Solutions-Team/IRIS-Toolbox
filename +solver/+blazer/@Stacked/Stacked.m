classdef Stacked ...
    < solver.blazer.Blazer

    properties
        ColumnsToRun (1, :) double = double.empty(1, 0)

        % StartIterationsFrom  Start iterations from data or from an extra
        % plain vanilla first-order simulation
        StartIterationsFrom (1, 1) string = "firstOrder"

        % Terminal  Take the terminal condition from the data, from an
        % extra plain vanilla first order simulation, or none
        Terminal (1, 1) string = "firstOrder"
    end


    properties (Constant)
        BLOCK_CONSTRUCTOR = @solver.block.Stacked
        LHS_QUANTITY_FORMAT = 'x(%g,t)'
        TYPES_ALLOWED_CHANGE_LOG_STATUS = { 1, 2, 5 }
    end
    

    methods
        function this = Stacked(varargin)
            this = this@solver.blazer.Blazer(varargin{:});
        end%


        function [inc, ptrEquations, ptrQuantities] = prepareIncidenceMatrix(this, varargin)
            PTR = @int16;
            inc = across(this.Incidence, 'Shift');

            if ~this.IsBlocks ...
                || isempty(varargin) || ~isa(varargin{1}, 'simulate.Data') || ~varargin{1}.HasExogenizedYX
                inc = inc(this.InxEquations, this.InxEndogenous);
                ptrEquations = PTR( find(this.InxEquations) ); %#ok<FNDSB>
                ptrQuantities = PTR( find(this.InxEndogenous) ); %#ok<FNDSB>
            else
                data = varargin{1};
                columns = data.FirstColumnFrame : data.LastColumnFrame;

                %
                % Update the index of endogenous quantities so that we
                % exclude variables that are exogenized in all period
                % of the current frame, and include shocks that are
                % endogenized at least in one period of the curent frame
                %
                inxEndogenous = this.InxEndogenous;

                %
                % Index of YX within quantities that are exogenized in all
                % periods of the current frame
                %
                inxExogenizedAllPeriods = reshape(all(data.InxExogenizedYX(:, columns), 2), 1, [ ]);

                %
                % Index of endogenous quantities within quantities that are not exogenized in
                % any period of the current frame
                %
                inxExogenizedSomePeriods = reshape(any(data.InxExogenizedYX(:, columns), 2), 1, [ ]);

                %
                % Index of E within quantities that are endogenized at
                % least in one period of the current frame
                %
                inxEndogenizedSomePeriods = reshape(any(data.InxEndogenizedE(:, columns), 2), 1, [ ]);
                 
                %
                % Update the index of endogenous quantities - they may now
                % include both variables and shocks
                %
                inxEndogenous ...
                    = (inxEndogenous & ~inxExogenizedAllPeriods) ...
                    | inxEndogenizedSomePeriods;

                inc = inc(this.InxEquations, inxEndogenous);
                ptrEquations = PTR(find(this.InxEquations)); %#ok<FNDSB>
                ptrQuantities = PTR(find(inxEndogenous)); %#ok<FNDSB>

                %
                % Add dummy equations, each including all variables that
                % are exogenized at least in one period of the frame, and
                % all shocks that are exogenized at least in one period of
                % the frame
                %
                [numEquations, numEndogenous] = size(inc);
                if numEndogenous>numEquations
                    numAddEquations = numEndogenous - numEquations;
                    incDummy = inxExogenizedSomePeriods | inxEndogenizedSomePeriods;
                    incDummy = incDummy(inxEndogenous);
                    incDummy = repmat(incDummy, numAddEquations, 1);
                    inc = [inc; incDummy];
                    ptrEquations = [ptrEquations, zeros(1, numAddEquations)];
                end
            end
        end%


        function setFrame(this, frameFromTo)
            this.ColumnsToRun = frameFromTo(1) : frameFromTo(end);
        end%
    end


    methods (Static)
        varargout = forModel(varargin)
    end
end
