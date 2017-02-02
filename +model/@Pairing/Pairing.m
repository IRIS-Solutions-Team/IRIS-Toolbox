classdef Pairing
    properties
        Autoexog
        Dtrend
        Link
        Revision
        Assignment
    end
    
    
    
    
    methods
        function this = Pairing(nQty, nEqn)
            if nargin==0
                nQty = 0;
                nEqn = 0;
            end
            this.Autoexog = model.Pairing.initAutoexog(nQty);
            this.Dtrend = model.Pairing.initDtrend(nEqn);
            this.Link = model.Pairing.initLink(nEqn);
            this.Revision = model.Pairing.initRevision(nEqn);
            this.Assignment = model.Pairing.initAssignment(nEqn);
        end
    end
    
    
    
    
    methods (Static)
        varargout = getAutoexog(varargin)
        varargout = chkConsistency(varargin)
        varargout = readAssignments(varargin)
        varargout = readAutoexog(varargin)
        varargout = setAutoexog(varargin)
        varargout = implementGet(varargin)
    end
    
    
    
    
    methods (Static)
        function auto = initAutoexog(nQty)
            PTR = @int16;
            auto = struct( );
            auto.Dynamic = repmat(PTR(0), 1, nQty);
            auto.Steady = repmat(PTR(0), 1, nQty);
        end
        
        
        
        
        function dtrend = initDtrend(nEqn)
            PTR = @int16;
            dtrend = repmat(PTR(0), 1, nEqn);
        end
        
        
        
        
        function link = initLink(nEqn)
            PTR = @int16;
            link = struct( );
            link.Lhs = repmat(PTR(0), 1, nEqn);
            link.Order = repmat(PTR(0), 1, nEqn);
        end
        
        
        
        
        function upd = initRevision(nEqn)
            PTR = @int16;
            upd = repmat(PTR(0), 1, nEqn);
        end

        
        
                
        function asgn = initAssignment(nEqn)
            PTR = @int16;
            asgn = struct( );
            asgn.Dynamic.Lhs = repmat(PTR(0), 1, nEqn);
            asgn.Dynamic.Type = repmat(solver.block.Type.UNKNOWN, 1, nEqn);
            asgn.Steady.Lhs = repmat(PTR(0), 1, nEqn);
            asgn.Steady.Type = repmat(solver.block.Type.UNKNOWN, 1, nEqn);
        end
    end
end
