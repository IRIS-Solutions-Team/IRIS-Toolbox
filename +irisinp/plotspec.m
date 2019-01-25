classdef plotspec < irisinp.generic
    properties
        ReportName = 'Plot Specs'  
        Value = NaN
        Omitted = cell.empty(1, 0)
        ValidFn = @(x, state) iscell(x) || (ischar(x) && mod(state.NUserLeft, 2)==1)
    end
    
    
    methods
        function this = preprocess(this, ~)
            if isempty(this.Value)
                this.Value = cell.empty(1, 0);
            elseif ischar(this.Value)
                this.Value = { this.Value };
            end
        end%
    end 
end
