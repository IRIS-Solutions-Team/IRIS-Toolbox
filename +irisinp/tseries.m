classdef tseries < irisinp.generic
    properties
        ReportName = 'Time Series';  
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) isa(x, 'tseries');
    end
end
