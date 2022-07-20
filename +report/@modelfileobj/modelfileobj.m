classdef modelfileobj < report.userinputobj
    
    properties
        filename = '';
        modelobj = [ ];
    end
    
    
    
    
    methods
        function this = modelfileobj(varargin)
            islogicalscalar = @(x) islogical(x) && isscalar(x);
            this = this@report.userinputobj(varargin{:});
            this.childof = {'report'};
            this.default = [ ...
                this.default, { ...
                'latexalias',false, islogicalscalar, false, ...
                'linenumbers',true, islogicalscalar, true, ...
                'lines', @all, @(x) isequal(x, @all) || isnumeric(x), true, ...
                'paramvalues',true, islogicalscalar, true, ....
                'separator','', @ischar, false, ...
                'syntax',true, islogicalscalar, true, ...
                'typeface','', @ischar, false, ...
                } ];
        end
        
        
        
        
        function [this, varargin] = specargin(this, varargin)
            if ~isempty(varargin) && ischar(varargin{1})
                this.filename = varargin{1};
                varargin(1) = [ ];
            end
            if ~isempty(varargin) && isa(varargin{1}, 'model')
                this.modelobj = varargin{1};
                varargin(1) = [ ];
            end
        end
    end
    
    
    
    
    methods (Access=protected, Hidden)
        varargout = printmodelfile(varargin)
        varargout = speclatexcode(varargin)
    end
end
