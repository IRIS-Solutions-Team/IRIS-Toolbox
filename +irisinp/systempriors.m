classdef systempriors < irisinp.generic
    properties
        ReportName = 'System Priors';  
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) isa(x,'systempriors');
    end
end
