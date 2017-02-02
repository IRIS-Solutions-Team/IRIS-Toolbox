classdef tdata < irisinp.generic
    properties
        ReportName = 'Time Series Data';
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) isnumeric(x) || islogical(x) ...
            || isa(x,'function_handle'); 
    end
end
