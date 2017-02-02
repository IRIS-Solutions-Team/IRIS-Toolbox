classdef bandobj < report.seriesobj
    
    properties
        Low = [ ];
        High = [ ];
    end
    
    methods
        
        function This = bandobj(varargin)
            This = This@report.seriesobj(varargin{:});
            This.default = [This.default,{ ...
                'bandformat',[ ],@(x) isempty(x) || ischar(x),false, ...
                'bandtypeface','\footnotesize',@ischar,true, ...
                'excludefromlegend',true,@islogicalscalar,true, ...
                'high','High',@ischar,true, ...
                'low','Low',@ischar,true, ...
                'plottype','patch', ...
                @(x) any(strcmpi(x,{'errorbar','line','patch'})), ...
                true, ...
                'relative',true,@islogicalscalar,true, ...
                'white',0.85, ...
                @(x) isnumeric(x) && all(x >= 0) && all(x <= 1), ...
                true, ...
                }];
        end
        
        function [This,varargin] = specargin(This,varargin)
            [This,varargin] = specargin@report.seriesobj(This,varargin{:});
            if ~isempty(varargin)
                This.Low = varargin{1};
                if isa(This.Low,'tseries')
                    This.Low = { This.Low };
                end
                varargin(1) = [ ];
            end
            if ~isempty(varargin)
                This.High = varargin{1};
                if isa(This.High,'tseries')
                    This.High = { This.High };
                end
                varargin(1) = [ ];
            end
        end
        
        function This = setoptions(This,varargin)
            This = setoptions@report.seriesobj(This,varargin{:});
            if ischar(This.options.bandformat)
                utils.warning('report', ...
                    ['The option ''bandformat'' in report/band is obsolete ', ...
                    'and will be removed from future IRIS versions. ', ...
                    'Use ''bandtypeface'' instead.']);
                This.options.bandtypeface = This.options.bandformat;
            end
            % Check consistency of `Low` and `High` relative to `X`. This function
            % needs to be finished.
            chkconsistency(This);
        end
        
        varargout = latexonerow(varargin)
        varargout = plot(varargin)
        varargout = chkconsistency(varargin)
        
    end
    
    methods (Access=protected,Hidden)
        varargout = speclatexcode(varargin)
    end
        
end
