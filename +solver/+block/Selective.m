classdef Selective ...
    < solver.block.Block

    properties (Constant)
        VECTORIZE
        PREAMBLE
    end


    methods
        function prepareForSolver(this, solverOptions, varargin)
            this.SolverOptions = solverOptions;
            this.SolverOptions.JacobCalculation = "ForwardDiff";
        end%


        function prepareJacob(this, varargin)
        end%
    end
end

