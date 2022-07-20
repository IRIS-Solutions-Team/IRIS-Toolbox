classdef alignobj < report.tabularobj

    properties
        K = 1;
    end
    
    methods
        
        function This = alignobj(varargin)            
            isnumericscalar = @(x) isnumeric(x) && isscalar(x);
            islogicalscalar = @(x) islogical(x) && isscalar(x);
            This = This@report.tabularobj(varargin{:});
            This.childof = {'report'};
            This.default = [This.default, {...
                'hspace',2,isnumericscalar,true, ...
                'separator','\medskip\par',@ischar,true, ...
                'sharecaption','auto', ...
                @(x) islogicalscalar(x) || isequal(lower(x),'auto'), ...
                true, ...
                'typeface','',@ischar,false, ...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
            isintscalar = @(x) isnumeric(x) && isscalar(x) && round(x)==x;
            This.caption = {'',''};
            if isintscalar(varargin{1}) && varargin{1} >= 0
                This.K = varargin{1};
                varargin(1) = [ ];
            else
                utils.error('report', ...
                    'Invalid input argument K in ALIGN.');
            end
            if isintscalar(varargin{1}) && varargin{1} > 0
                This.ncol = varargin{1};
                varargin(1) = [ ];
            else
                utils.error('report', ...
                    'Invalid input argument NCOL in ALIGN.');
            end
        end
        
        function This = setoptions(This,varargin)
            This = setoptions@report.tabularobj(This,varargin{:});
            This.options.long = false;
            This.options.sideways = false;
        end
        
        
    end
    
    methods (Access = protected, Hidden)
   
        varargout = speclatexcode(varargin)
        
        function Flag = accepts(This)
            Flag = length(This.children) < This.K;
        end
        
    end
    
end
