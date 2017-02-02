classdef figureobj < report.basefigureobj

    
    properties
    end

    
    methods
        function This = figureobj(varargin)
            This = This@report.basefigureobj(varargin{:});
        end
        
        
        function [This,varargin] = specargin(This,varargin)
        end
        
        
        function This = setoptions(This,varargin)
            This = setoptions@report.basefigureobj(This,varargin{:});
        end
    end

    
    methods (Access=protected,Hidden)        
        varargout = myplot(varargin)
    end
    
    
end
