classdef Gradient
    properties
        Dynamic (3, :) cell = cell(3, 0)
        Steady (3, :) cell = cell(3, 0)
    end
    
    
    methods
        function this = Gradient(n)
            if nargin==0
                return
            end
            this.Dynamic = cell(3, n);
            this.Steady = cell(3, n);
        end%
        
        varargout = implementGet(varargin)
        varargout = size(varargin)
    end
    
    
    methods (Static)
        varargout = array2symb(varargin)
        varargout = diff(varargin)
        varargout = symb2array(varargin)         
        varargout = lookupIdsWithinEquation(varargin)
        varargout = repmatGradient(varargin)
    end
end
