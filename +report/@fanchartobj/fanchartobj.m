classdef fanchartobj < report.seriesobj
  
    properties
        std = [ ];
        prob = [ ];
    end
    
    methods
        
        function This = fanchartobj(varargin)
            This = This@report.seriesobj(varargin{:});
            This.default = [This.default,{...
                'asym',1,@(x) (isnumeric(x) || istseries(x)) && all(x >= 0),false,...
                'exclude',false,@(x) (isnumeric(x)...
                    && all((x == 1) + (x == 0))) || islogical(x),false, ...
                'factor',1,@(x) isnumeric(x) && all(x >= 0),false,...
                'fanlegend',Inf,@(x) isempty(x) ...
                    || (isnumericscalar(x) && (isnan(x) || isinf(x))) ...
                    || iscellstrwithnans(x) || ischar(x),false, ...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
            [This,varargin] = specargin@report.seriesobj(This,varargin{:});
            if ~isempty(varargin)
                This.std = varargin{1};
                varargin(1) = [ ];
            end
            if ~isempty(varargin)
                This.prob = varargin{1};
                if isnumeric(This.prob)
                    This.prob = sort(This.prob(:));
                    i = 1;
                    while i<length(This.prob)
                        if This.prob(i) == This.prob(i+1)
                            This.prob(i+1) = [ ];
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