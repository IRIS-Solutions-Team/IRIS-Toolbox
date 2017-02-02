classdef systeq
    properties
        Quantity = model.Quantity;
        Equation = model.Equation;
    end
    
    
    
    
    methods
        varargout = addEndogenous(varargin)
        varargout = addShock(varargin)
        varargout = addExogenous(varargin)
        varargout = addEquation(varargin)
    end
    
    
    
    
    methods (Access=protected)
        varargout = addQuantity(varargin)
        varargout = addEquation(varargin)
    end
end