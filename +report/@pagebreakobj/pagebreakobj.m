classdef pagebreakobj < report.genericobj

    methods
        
        function This = pagebreakobj(varargin)
            This = This@report.genericobj(varargin{:});
            This.childof = {'report'};
            This.default = [This.default,{ }];
        end
        
        function [This,varargin] = specargin(This,varargin)
        end
        
        function This = setoptions(This,varargin)
            This = setoptions@report.genericobj(This,varargin{:});
            This.options.separator = '';
        end
        
    end
    
    methods (Access=protected,Hidden)
        
        varargout = speclatexcode(varargin)
        
    end
    
end