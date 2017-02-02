classdef rpteq < irisinp.generic
    properties
        ReportName = 'Report Equations';
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) isa(x,'rpteq');
    end
end
