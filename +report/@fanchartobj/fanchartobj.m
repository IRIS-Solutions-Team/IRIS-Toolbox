classdef fanchartobj < report.seriesobj
  
    properties
        std = [ ];
        prob = [ ];
    end
    
    methods
        
        function this = fanchartobj(varargin)
            isnumericscalar = @(x) isnumeric(x) && isscalar(x);
            this = this@report.seriesobj(varargin{:});
            this.default = [this.default, {...
                'asym', 1, @(x) (isnumeric(x) || isa(x, 'Series')) && all(x >= 0), false, ...
                'exclude', false, @(x) (isnumeric(x)...
                    && all((x == 1) + (x == 0))) || islogical(x), false, ...
                'factor', 1, @(x) isnumeric(x) && all(x >= 0), false, ...
                'fanlegend', Inf, @(x) isempty(x) ...
                    || (isnumericscalar(x) && (isnan(x) || isinf(x))) ...
                    ||  all(cellfun(@(y) ischar(y) || isequaln(y, NaN), x)) || ischar(x), false, ...
                }];
        end
        
        function [this, varargin] = specargin(this, varargin)
            [this, varargin] = specargin@report.seriesobj(this, varargin{:});
            if ~isempty(varargin)
                this.std = varargin{1};
                varargin(1) = [ ];
            end
            if ~isempty(varargin)
                this.prob = varargin{1};
                if isnumeric(this.prob)
                    this.prob = sort(this.prob(:));
                    i = 1;
                    while i<length(this.prob)
                        if this.prob(i) == this.prob(i+1)
                            this.prob(i+1) = [ ];
                        else
                            i = i + 1;
                        end;
                    end;
                end
                varargin(1) = [ ];
            end
        end
        
        varargout = plot(varargin)
        
    end
    
end
