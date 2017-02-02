classdef datesTseries < irisinp.dates
    properties
        SpecRangeFlag
    end
    
    
    methods
        function this = datesTseries(SpecRangeFlag,varargin)
            this = this@irisinp.dates(varargin{:});
            this.ReportName = 'Time Series Dates';
            this.Omitted = Inf;
            this.SpecRangeFlag = SpecRangeFlag;
        end
        
        
        function this = preprocess(this,Func)
            this = preprocess@irisinp.dates(this,Func);
            if isequal(this.Value,Inf) || isequal(this.Value,@all)
                ixPrimary = strcmp(Func.InpClassName,'tseriesPrimary');
                if any(ixPrimary)
                    x = Func.Inp{ixPrimary}.Value;                    
                    specDates = x.start + (0 : size(x.data,1)-1);
                    if strcmpi(this.SpecRangeFlag,'max')
                        ixObs = any(~isnan(x.data(:,:)),2);
                    elseif strcmpi(this.SpecRangeFlag,'min')
                        ixObs = all(~isnan(x.data(:,:)),2);
                    else
                        ixObs = false(size(specDates));
                    end
                    this.Value = specDates(ixObs);
                end
            end
        end
    end
end
