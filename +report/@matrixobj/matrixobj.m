classdef matrixobj < report.tabularobj & report.condformatobj
    
    properties
        data = [ ];
    end
    
    methods
        
        function This = matrixobj(varargin)
            isnumericscalar = @(x) isnumeric(x) && isscalar(x);
            islogicalscalar = @(x) islogical(x) && isscalar(x);
            This = This@report.tabularobj(varargin{:});
            This = This@report.condformatobj( );
            This.childof = {'report','align'};
            This.default = [This.default,{ ...
                'colnames',{ },@iscellstr,true, ...
                'condformat',[ ], ...
                @(x) isempty(x) || ( ...
                isstruct(x) ...
                && isfield(x,'test') && isfield(x,'format') ...
                && iscellstr({x.test}) && iscellstr({x.format}) ), ...
                true, ...
                'format','%.2f',@ischar,true,...
                'heading','',@ischar,true,...
                'inf','$\infty$',@ischar,true,...
                'nan','$\cdots$',@ischar,true,...
                'purezero','',@ischar,true, ...
                'printedzero','',@ischar,true, ...
                'rownames',{ },@iscellstr,true,...
                'rotatecolnames',true, ...
                @(x) islogicalscalar(x) || isnumericscalar(x),true, ...
                'separator','\medskip\par',@ischar,true, ...
                'typeface','',@ischar,false, ...
                }];
            This.vline = [ ];
            This.highlight = [ ];
            This.nlead = 0;
        end
        
        function [This,varargin] = specargin(This,varargin)
            if ~isempty(varargin)
                This.data = varargin{1};
                varargin(1) = [ ];
            end
            This.nrow = size(This.data,1);
            This.ncol = size(This.data,2);
        end
        
        function This = setoptions(This,varargin)
            This = setoptions@report.tabularobj(This,varargin{:});
            % Make sure numel of rownames equals nrow, and numel of
            % colnames equals ncol.
            if numel(This.options.rownames) < This.nrow
                This.options.rownames(end+1:This.nrow) = {''};
            else
                This.options.rownames = This.options.rownames(1:This.nrow);
            end
            if numel(This.options.colnames) < This.ncol
                This.options.colnames(end+1:This.ncol) = {''};
            else
                This.options.colnames = This.options.colnames(1:This.ncol);
            end
            This = assign(This,This.options.condformat);
        end
        
        varargout = anyrowname(varargin)
        varargout = anycolname(varargin)
        
    end

    methods (Access=protected,Hidden)
        varargout = speclatexcode(varargin)
    end
    
end
