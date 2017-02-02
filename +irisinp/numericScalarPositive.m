classdef numericScalarPositive < irisinp.generic
    properties
        ReportName = 'Positive Numeric Scalar';  
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) isnumericscalar(x) && x>0;
    end
end
