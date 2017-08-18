classdef mlist < irisinp.generic   
    properties
        ReportName = 'List';
        Value = NaN;
        Omitted = @all;
        ValidFn = @(x, state) iscellstr(x) || isa(x, 'rexp') ...
            || isequal(x, @all) || isequal(x, Inf) ...
            || ( ischar(x) && state.IsOptAfter );
    end
    
    
    methods
        function preprocess(this, varargin)
            preprocess@irisinp.generic(this, varargin);
            if isequal(this.Value, Inf)
                this.Value = @all;
            end
        end
    end
end
