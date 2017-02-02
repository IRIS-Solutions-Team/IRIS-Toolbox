classdef arrayobj < report.tabularobj
    
    properties
        data = { };
    end
    
    methods
        
        function This = arrayobj(varargin)
            This = This@report.tabularobj(varargin{:});
            This.childof = {'report','align'};
            This.default = [This.default,{...
                'format','%.2f',@ischar,true,...
                'inf','$\infty$',@ischar,true,...
                'heading','',@(x) isempty(x) || ischar(x) || iscell(x),true,...
                'nan','$\cdots$',@ischar,true,...
                'purezero','',@ischar,true, ...
                'printedzero','',@ischar,true, ...
                'separator','\medskip\par',@ischar,true, ...
                'typeface','',@ischar,false, ...
                }];
            This.vline = [ ];
            This.highlight = [ ];
            This.nlead = 0;
        end
        
        function [This,varargin] = specargin(This,varargin)
            if ~isempty(varargin)
                if iscell(varargin{1})
                    This.data = varargin{1};
                    varargin(1) = [ ];
                else
                    utils.error('report', ...
                        'Input data for array objects must be cell arrays.');
                end
            end
        end
        
    end
    
    methods (Access = protected, Hidden)   
        varargout = speclatexcode(varargin)
    end
    
end