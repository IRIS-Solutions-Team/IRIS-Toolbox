classdef plotspec < irisinp.generic
    properties
        ReportName = 'Plot Specs';  
        Value = NaN;
        Omitted = { };
        ValidFn = @(x, state) ischar(x) && ~iseven(state.NUserLeft);
    end
    
    
    methods
        function this = preprocess(this, ~)
            if isempty(this.Value)
                this.Value = { };
            elseif ischar(this.Value)
                this.Value = { this.Value };
            end
        end
    end 
end
