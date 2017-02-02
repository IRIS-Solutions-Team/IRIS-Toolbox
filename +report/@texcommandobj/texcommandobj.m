classdef texcommandobj < report.genericobj
    
    properties
    end
    
    methods
        
        function This = texcommandobj(varargin)
            This = This@report.genericobj(varargin{:});
            This.childof = {'report'};
            This.default = [This.default,{ ...
                'separator','\medskip\par',@ischar,true, ...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
        end
        
    end
    
    methods (Access=protected,Hidden)
        
        varargout = speclatexcode(varargin)
        
    end
    
end