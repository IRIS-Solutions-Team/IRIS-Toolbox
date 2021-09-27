classdef dates < irisinp.generic
    properties
        ReportName = 'Dates'
        Value = NaN
        Omitted = @error
        ValidFn = @validate.date
    end


    methods
        function this = preprocess(this,~)
        end%
    end
end
