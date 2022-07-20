classdef subheadingobj < report.genericobj
    
    methods
        
        function This = subheadingobj(varargin)
            islogicalscalar = @(x) islogical(x) && isscalar(x);
            This = This@report.genericobj(varargin{:});
            This.childof = {'table'};
            This.default = [This.default,{ ...
                'justify','l', ...
                @(x) ischar(x) && any(strncmpi(x,{'l','c','r'},1)),true, ...
                'stretch',true,islogicalscalar,true, ...
                'separator','',@ischar,false, ...
                'typeface','\itshape\bfseries',@ischar,false, ...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
        end
        
        function This = setoptions(This,varargin)
            This = setoptions@report.genericobj(This,varargin{:});
            This.options.justify = lower(This.options.justify(1));
        end
        
    end
    
    methods (Access=protected,Hidden)
        
        varargout = speclatexcode(varargin)
        
    end
    
end
