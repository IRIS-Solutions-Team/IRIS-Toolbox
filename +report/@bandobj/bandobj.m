classdef bandobj < report.seriesobj
    
    properties
        Low = [ ];
        High = [ ];
    end
    
    methods
        
        function this = bandobj(varargin)
            islogicalscalar = @(x) islogical(x) && isscalar(x);
            this = this@report.seriesobj(varargin{:});
            this.default = [this.default,{ ...
                'bandformat',[ ],@(x) isempty(x) || ischar(x),false, ...
                'bandtypeface','\footnotesize',@ischar,true, ...
                'ExcludeFromLegend',true,islogicalscalar,true, ...
                'high','High',@ischar,true, ...
                'low','Low',@ischar,true, ...
                'plottype','patch', ...
                @(x) any(strcmpi(x,{'errorbar','line','patch'})), ...
                true, ...
                'Relative',true,islogicalscalar,true, ...
                'White',0.85, ...
                @(x) isnumeric(x) && all(x >= 0) && all(x <= 1), ...
                true, ...
            }];
        end
        
        function [this,varargin] = specargin(this,varargin)
            [this,varargin] = specargin@report.seriesobj(this,varargin{:});
            if ~isempty(varargin)
                this.Low = varargin{1};
                if isa(this.Low,'Series')
                    this.Low = { this.Low };
                end
                varargin(1) = [ ];
            end
            if ~isempty(varargin)
                this.High = varargin{1};
                if isa(this.High,'Series')
                    this.High = { this.High };
                end
                varargin(1) = [ ];
            end
        end
        
        function this = setoptions(this,varargin)
            this = setoptions@report.seriesobj(this,varargin{:});
            if ischar(this.options.bandformat)
                this.options.bandtypeface = this.options.bandformat;
            end
        end
        
        varargout = latexonerow(varargin)
        varargout = plot(varargin)
        
    end
    
    methods (Access=protected,Hidden)
        varargout = speclatexcode(varargin)
    end
        
end
