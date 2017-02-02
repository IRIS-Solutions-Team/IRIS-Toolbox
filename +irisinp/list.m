classdef list < irisinp.generic   
    properties
        ReportName = 'List';
        Value = NaN;
        Omitted = @error;
        ValidFn = @iscellstr; 
    end
end
