classdef sectionobj < report.genericobj
    
    methods
        
        function This = sectionobj(varargin)
            This = This@report.genericobj(varargin{:});
            This.childof = {'report'};
            This.default = [This.default,{ ...
                'numbered',true,@islogical,true,...
                'separator','',@ischar,false,...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
        end
        
    end
    
    methods (Access=protected,Hidden)
        
        varargout = speclatexcode(varargin)
        
    end
    
end