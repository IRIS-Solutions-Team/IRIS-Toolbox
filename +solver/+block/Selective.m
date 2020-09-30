classdef Selective ...
    < solver.block.Block

    properties (Constant)
        VECTORIZE
        PREAMBLE
    end


    methods
        function prepareForSolver(this, solverOptions, varargin)
            this.SolverOptions = solverOptions;
            for i = 1 : numel(this.SolverOptions)
                this.SolverOptions(i).JacobCalculation = "ForwardDiff";
            end
        end%


        function prepareJacob(this, varargin)
        end%
    end
end

