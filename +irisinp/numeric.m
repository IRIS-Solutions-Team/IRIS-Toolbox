classdef numeric < irisinp.generic
    properties
        ReportName = 'Numeric';  
        Value = NaN;
        Omitted = @error;
        ValidFn = @isnumeric;
    end
end
