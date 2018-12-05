classdef axesOrEmpty < irisinp.generic
    properties
        ReportName = 'Axes Handle or Empty'
        Value = NaN;
        Omitted = @gca;
        ValidFn = @(x) isequal(x, gobjects(0)) || ...
                       ( length(x)==1 ...
                         && ishghandle(x) && strcmp(get(x, 'type'), 'axes') );
    end
end
