classdef dates < irisinp.generic
    properties
        ReportName = 'Dates';
        Value = NaN;
        Omitted = @error;
        ValidFn = @DateWrapper.validateDateInput;
    end
    

    methods
        function this = preprocess(this,~)
            if ischar(this.Value)
                this.Value = textinp2dat(this.Value);
            end
        end
    end
end
