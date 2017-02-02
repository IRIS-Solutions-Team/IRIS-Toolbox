classdef vlineobj < report.annotateobj
    
    methods
        
        function This = vlineobj(varargin)
            This = This@report.annotateobj(varargin{:});
        end
        
        varargout = plot(varargin)
        
    end
    
end