classdef Equation < model.component.Insertable
    properties
        Input = cell.empty(1, 0)     % User input equations
        Type = int8.empty(1, 0)      % Equation type
        Label = cell.empty(1, 0)     % User escription attached to equation
        Alias = cell.empty(1, 0)     % LaTeX representation of equation
        Dynamic = cell.empty(1, 0)   % Parsed dynamic equations
        Steady = cell.empty(1, 0)    % Parsed steady equations
        IxHash = logical.empty(1, 0) % True for hash-signed equations
    end
    
    
    properties (Constant, Hidden)
        TYPE_ORDER = int8([1, 2, 3, 4, 5, 6]);
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
