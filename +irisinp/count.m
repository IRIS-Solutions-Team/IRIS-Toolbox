classdef count < irisinp.generic
    methods
        function this = count(ReportName,varargin)
            this = this@irisinp.generic(varargin{:});
            this.ReportName = ReportName;
        end
    end
    
    
    properties
        ReportName = '';
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) isintscalar(x) && x >= 0;
    end
end
