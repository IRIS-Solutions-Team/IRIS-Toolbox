classdef dbaseOrEmpty < irisinp.generic   
    properties
        ReportName = 'Dbase or Empty';
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) isequal(x, [ ]) || isstruct(x);
    end
end
