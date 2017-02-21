classdef Behavior
    properties
        InvalidDotAssign = 'Error'
        DotReferenceFunc = [ ]
    end
    
    
    
    
    methods
        varargout = implementGet(varargin)
        varargout = implementSet(varargin)
        varargout = saveobj(varargin)
    end
end
