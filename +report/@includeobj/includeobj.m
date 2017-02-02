classdef includeobj < report.userinputobj

    properties
        filename = '';
    end
    
    methods
        
        function This = includeobj(varargin)
            This = This@report.userinputobj(varargin{:});
            This.default = [This.default,{ ...
                'lines',Inf,@isnumeric,true, ...
                'separator','\medskip\par',@ischar,false, ...
                'typeface','',@ischar,false, ...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
            if ~isempty(varargin)
                % Keep the file name only, and read the content of the file at the time the
                % LaTeX code is being produced.
                This.filename = varargin{1};
                varargin(1) = [ ];
            end
        end
        
    end
    
    methods (Access=protected,Hidden)
        
        varargout = speclatexcode(varargin)
        
    end
    
end