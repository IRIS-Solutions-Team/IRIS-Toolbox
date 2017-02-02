classdef funch < irisinp.generic   
    properties
        ReportName = 'Function Handle';
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) isa(x,'function_handle'); 
    end
end
