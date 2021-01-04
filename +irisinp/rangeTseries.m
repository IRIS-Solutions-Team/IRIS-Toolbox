classdef rangeTseries < irisinp.range
    methods
        function this = rangeTseries()
            this = this@irisinp.range();
            this.ReportName = 'Time Series Range';
            this.Omitted = Inf;
        end
        
        
        function this = preprocess(this,Func)
            this = preprocess@irisinp.range(this,Func);
            ixPrimary = strcmp(Func.InpClassName,'tseriesPrimary');
            if any(ixPrimary)
                x = Func.Inp{ixPrimary}.Value;
                flag = all(freqcmp(this.Value,x));
                if ~flag
                    utils.error('inp:rangeTseries:preprocess', ...
                        ['Input range frequency fails to match ', ...
                        'input time series frequency.']);
                end
                [~, ~, this.Value] = resolveRange(x, this.Value);
            end
        end
    end
end

