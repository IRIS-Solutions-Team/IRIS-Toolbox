classdef tsydney < sydney
    
    
    properties
        TRec = [ ];
        Ref = { };
        InpName = '';
    end
    
    
    methods
        function This = tsydney(varargin)
            if isempty(varargin)
                return
            end
            if length(varargin) == 1 && isa(varargin{1},'tsydney')
                This = varargin{1};
                return
            end
            This.Func = '';
            This.args = varargin{1};
            This.lookahead = 0;
            This.numd = [ ];
            This.InpName = varargin{2};
            This.TRec = varargin{3};
            This.Ref = varargin(4:end);
        end
    end
    
    
    methods
        function C = myatomchar(This)
            tr = This.TRec;
            ref = myprintref(This);
            if tr.Shift == 0
                C = sprintf('?(t%s)',ref);
            else
                C = sprintf('?(t%+g%s)',tr.Shift,ref);
            end
        end        
        
        function C = myprintref(This)
            C = '';
            if isempty(This.Ref)
                return
            end
            for i = 1 : length(This.Ref)
                r = sprintf('%g,',This.Ref{1});
                C = [C,', [',r(1:end-1),']']; %#ok<AGROW>
            end
        end
        
        
        varargout = myeval(varargin)
        

        % Tseries functions where the result for period t depends on some other
        % observations (lags or leads).
        function This = apct(varargin)
            This = tsydney.parse('apct',varargin{:});
        end        
        function This = bwf(varargin)
            This = tsydney.parse('bwf',varargin{:});
        end        
        function This = bwf2(varargin)
            This = tsydney.parse('bwf2',varargin{:});
        end        
        function This = cumprod(varargin)
            This = tsydney.parse('cumprod',varargin{:});
        end                
        function This = cumsum(varargin)
            This = tsydney.parse('cumsum',varargin{:});
        end        
        function This = detrend(varargin)
            This = tsydney.parse('detrend',varargin{:});
        end        
        function This = diff(varargin)
            This = tsydney.parse('diff',varargin{:});
        end        
        function This = expsmooth(varargin)
            This = tsydney.parse('expsmooth',varargin{:});
        end        
        function This = hpf(varargin)
            This = tsydney.parse('hpf',varargin{:});
        end        
        function This = hpf2(varargin)
            This = tsydney.parse('hpf2',varargin{:});
        end        
        function This = llf(varargin)
            This = tsydney.parse('llf',varargin{:});
        end        
        function This = llf2(varargin)
            This = tsydney.parse('llf2',varargin{:});
        end        
        function This = mean(varargin)
            This = tsydney.parse('mean',varargin{:});
        end        
        function This = moving(varargin)
            This = tsydney.parse('moving',varargin{:});
        end        
        function This = pct(varargin)
            This = tsydney.parse('pct',varargin{:});
        end        
        function This = std(varargin)
            This = tsydney.parse('std',varargin{:});
        end                
        function This = trend(varargin)
            This = tsydney.parse('trend',varargin{:});
        end        
        function This = x12(varargin)
            This = tsydney.parse('x12',varargin{:});
        end                
    end
    
    
    methods (Static)
        varargout = parse(varargin)
    end
    
    
end
