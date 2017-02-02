classdef highlightobj < report.annotateobj

    methods
        
        function This = highlightobj(varargin)
            This = This@report.annotateobj(varargin{:});
        end
        
        varargout = plot(varargin)
        
    end
    
end