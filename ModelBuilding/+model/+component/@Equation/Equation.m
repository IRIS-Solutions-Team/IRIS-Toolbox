classdef Equation < model.component.Insertable
    properties
        Input = cell(1, 0) % User input equations
        Type = repmat(model.component.Equation.TYPE(0), 1, 0) % Equation type
        Label = cell(1, 0) % User escription attached to equation
        Alias = cell(1, 0) % LaTeX representation of equation
        Dynamic = cell(1, 0) % Parsed dynamic equations
        Steady = cell(1, 0) % Parsed steady equations
        IxHash = false(1, 0) % True for hash-signed equations
    end
    
    
    
    
    properties (Constant, Hidden)
        TYPE_ORDER = model.component.Equation.TYPE([1, 2, 3, 4, 5, 6]);
    end




    methods
        varargout = getLabelOrInput(varargin)
        varargout = implementDisp(varargin)
        varargout = implementGet(varargin)
        varargout = isCompatible(varargin)
        varargout = length(varargin)
        varargout = postparse(varargin)
        varargout = readEquations(varargin)
        varargout = readDtrends(varargin)
        varargout = readLinks(varargin)
        varargout = readRevisions(varargin)
        varargout = saveObject(varargin)
        varargout = selectType(varargin)
        varargout = size(varargin)
    end
    
    
    
    
    methods (Static)
        varargout = extractInput(varargin)
        varargout = loadObject(varargin)
    end
end
