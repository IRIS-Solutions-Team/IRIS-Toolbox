classdef Date < double
    methods
        function this = Date(varargin)
            this = this@double(varargin{:});
        end
        
        
        
        
        function disp(this)
            size_ = size(this);
            strSize = sprintf('%gx', size_);
            strSize(end) = '';
            freq = datfreq(this);
            if isempty(freq)
                freqName = 'Empty';
            elseif all(freq(1)==freq)
                freqName = dates.Date.printFreqName(freq(1));
                freqName = [freqName{1}, ' Frequency'];
            else
                freqName = 'Mixed Frequency';
            end
            fprintf('\t%s %s Date(s)\n', strSize, freqName);
            textfun.loosespace( );
            x = dat2str(this);
            disp(x);
            textfun.loosespace( );
        end
        
        
        
        
        function x = plus(a, b)
            if (isa(a, 'dates.Date') && isa(b, 'dates.Date')) ...
                    || ~isnumeric(a) || ~isnumeric(b)
                error('...');
            end
            x = builtin('plus', a, b);
            x = dates.Date(x);
        end
        
        
        
        
        function x = minus(a, b)
            if ~isnumeric(a) || ~isnumeric(b)
                error('...');
            end
            if isa(a, 'dates.Date') && isa(b, 'dates.Date')
                freqA = datfreq(a);
                freqB = datfreq(b);
                d = int32(100*(freqA -  freqB));
                isValid = all(d==int32(0));
                if ~isValid
                    error('...')
                end
            end
            x = builtin('minus', a, b);
            if isa(a, 'dates.Date') && isa(b, 'dates.Date')
                return
            end
            x = dates.Date(x);
        end
        
        
        
        
        function this = colon(varargin)
            if nargin==2
                [from, to] = varargin{:};
                step = 1;
            elseif nargin==3
                [from, step, to] = varargin{:};
            end
            this = dates.Date(builtin('colon', from, step, to));
        end
        
        
        
        
        function flag = eq(d1, d2)
            flag = round(d1*100)==round(d2*100);
        end
    end
    
    
    
    
    methods (Static)
        function chkMixedFrequency(freq)
            if isempty(freq)
                return
            end
            if any(freq(1)~=freq)
                freq = unique(freq, 'stable');
                lsFreq = dates.Date.printFreqName(freq);
                temp = sprintf('%s x ', lsFreq{:});
                temp(end-2:end) = '';
                throw( ...
                    exception.Base('Dates:MixedFrequency', 'error'), ...
                    temp ...
                    ); %#ok<GTARG>
            end
        end
        
        
        
        
        function prt = printFreqName(f)
            freqName = irisget('FreqName');            
            if isnumeric(f)
                f = num2cell(f);
            end
            prt = values(freqName, f);
        end
    end
end
