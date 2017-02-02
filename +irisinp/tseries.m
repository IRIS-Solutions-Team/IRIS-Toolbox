classdef tseries < irisinp.generic
    properties
        ReportName = 'Time Series';  
        Value = NaN;
        Omitted = @error;
        ValidFn = @istseries;
    end
end
