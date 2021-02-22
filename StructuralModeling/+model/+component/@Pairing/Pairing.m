classdef Pairing
    properties
        Autoswap
        Dtrend
        Revision
        Assignment
    end


    methods
        function this = Pairing(numQuantities, numEquations)
            if nargin==0
                numQuantities = 0;
                numEquations = 0;
            end
            this.Autoswap = model.component.Pairing.initAutoswap(numQuantities);
            this.Dtrend = model.component.Pairing.initDtrend(numEquations);
            this.Assignment = model.component.Pairing.initAssignment(numEquations);
        end%%
    end


    properties (Dependent)
        % Autoexog  Legacy property
        Autoexog
    end


    methods
        function this = set.Autoexog(this, value)
            auto = model.component.AutoswapStruct( );
            auto.Simulate = value.Dynamic;
            auto.Steady = value.Steady;
            this.Autoswap = auto;
        end%
    end
    
    
    methods (Static)
        varargout = getAutoswap(varargin)
        varargout = checkConsistency(varargin)
        varargout = readAssignments(varargin)
        varargout = readAutoswap(varargin)
        varargout = setAutoswap(varargin)
        varargout = implementGet(varargin)
    end
    
    
    methods (Static)
        function auto = initAutoswap(numQuantities)
            PTR = @int16;
            auto = model.component.AutoswapStruct( );
            auto.Simulate = repmat(PTR(0), 1, numQuantities);
            auto.Steady = repmat(PTR(0), 1, numQuantities);
        end%
        
        
        function dtrend = initDtrend(numEquations)
            PTR = @int16;
            dtrend = repmat(PTR(0), 1, numEquations);
        end%
        
        
        function asgn = initAssignment(numEquations)
            PTR = @int16;
            asgn = struct( );
            asgn.Dynamic.Lhs = repmat(PTR(0), 1, numEquations);
            asgn.Dynamic.Type = repmat(solver.block.Type.UNKNOWN, 1, numEquations);
            asgn.Steady.Lhs = repmat(PTR(0), 1, numEquations);
            asgn.Steady.Type = repmat(solver.block.Type.UNKNOWN, 1, numEquations);
        end%
    end
end

