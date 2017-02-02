classdef axes < irisinp.generic
    properties
        ReportName = 'Axes Handle';  
        Value = NaN;
        Omitted = @gca;
        ValidFn = @(x) length(x)==1 ...
            && ishghandle(x) && strcmp(get(x, 'type'), 'axes');
    end
end
