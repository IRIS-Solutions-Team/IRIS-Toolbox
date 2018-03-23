classdef Gradient
    properties
        Dynamic = cell(2, 0)
        Steady = cell(2, 0)
    end
    
    
    
    
    methods
        function this = Gradient(n)
            if nargin==0
                return
            end
            this.Dynamic = cell(2, n);
            this.Steady = cell(2, n);
        end
        
        
        
        
        varargout = implementGet(varargin)
        varargout = size(varargin)
    end
    
    
    
    
    methods (Static)
        varargout = array2symb(varargin)
        varargout = diff(varargin)
        varargout = symb2array(varargin)         
    end
end
