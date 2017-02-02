classdef rangeTseries < irisinp.range
    properties
        SpecRangeFlag
    end
    

    methods
        function this = rangeTseries(SpecRangeFlag,varargin)
            this = this@irisinp.range(varargin{:});
            this.ReportName = 'Time Series Range';
            this.Omitted = Inf;
            this.SpecRangeFlag = SpecRangeFlag;
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
                this.Value = ...
                    specrange(x,this.Value,this.SpecRangeFlag);
            end
        end
    end
end
