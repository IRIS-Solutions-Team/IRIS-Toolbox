classdef dbase < irisinp.generic   
    properties
        ReportName = 'Dbase';
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) isstruct(x) && ~isempty(x);
    end
end
