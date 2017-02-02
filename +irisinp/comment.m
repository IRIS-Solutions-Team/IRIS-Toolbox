classdef comment < irisinp.generic
    properties
        ReportName = 'Comment';
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) ischar(x) || iscell(x); 
    end
end
