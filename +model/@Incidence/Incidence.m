classdef Incidence
    properties
        Shift
        Matrix
    end
    
    
    
    
    methods
        function this = Incidence(nEqtn, nQuan, minSh, maxSh)
            if nargin==0
                return
            end
            this.Shift = (minSh-1) : (maxSh+1);
            nsh = length(this.Shift);
            this.Matrix = logical( sparse(nEqtn, nQuan*nsh) );
        end
    end
    
    
    
    
    methods
        varargout = across(varargin)
        varargout = fill(varargin)
        varargout = find(varargin)
        varargout = getMaxShift(varargin)
        varargout = implementGet(varargin)
        varargout = isCompatible(varargin)
        varargout = nofShift(varargin)
        varargout = selectShift(varargin)
        varargout = selectEquation(varargin)
        varargout = size(varargin)
        varargout = zero(varargin)
    end
    
    
    
    
    methods (Static)
        varargout = getIncidenceEps(varargin)        
    end
end
