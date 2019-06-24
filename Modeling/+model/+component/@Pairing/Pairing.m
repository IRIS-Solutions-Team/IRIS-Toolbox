classdef Pairing
    properties
        Autoswap
        Dtrend
        Revision
        Assignment
    end


    methods
        function this = Pairing(numOfQuantities, numOfEquations)
            if nargin==0
                numOfQuantities = 0;
                numOfEquations = 0;
            end
            this.Autoswap = model.component.Pairing.initAutoswap(numOfQuantities);
            this.Dtrend = model.component.Pairing.initDtrend(numOfEquations);
            this.Revision = model.component.Pairing.initRevision(numOfEquations);
            this.Assignment = model.component.Pairing.initAssignment(numOfEquations);
        end%%
    end
    
    
    methods (Static)
        varargout = getAutoswap(varargin)
        varargout = chkConsistency(varargin)
        varargout = readAssignments(varargin)
        varargout = readAutoswap(varargin)
        varargout = setAutoswap(varargin)
        varargout = implementGet(varargin)
    end
    
    
    methods (Static)
        function auto = initAutoswap(numOfQuantities)
            PTR = @int16;
            auto = struct( );
            auto.Simulate = repmat(PTR(0), 1, numOfQuantities);
            auto.Steady = repmat(PTR(0), 1, numOfQuantities);
        end%
        
        
        function dtrend = initDtrend(numOfEquations)
            PTR = @int16;
            dtrend = repmat(PTR(0), 1, numOfEquations);
        end%
        
        
        function upd = initRevision(numOfEquations)
            PTR = @int16;
            upd = repmat(PTR(0), 1, numOfEquations);
        end%

                
        function asgn = initAssignment(numOfEquations)
            PTR = @int16;
            asgn = struct( );
            asgn.Dynamic.Lhs = repmat(PTR(0), 1, numOfEquations);
            asgn.Dynamic.Type = repmat(solver.block.Type.UNKNOWN, 1, numOfEquations);
            asgn.Steady.Lhs = repmat(PTR(0), 1, numOfEquations);
            asgn.Steady.Type = repmat(solver.block.Type.UNKNOWN, 1, numOfEquations);
        end%
    end
end

