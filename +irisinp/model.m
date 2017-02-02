classdef model < irisinp.generic
    properties
        ReportName = 'Model';
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x) isa(x, 'model');
    end
    
    
    methods
        function this = model(MaxNAlt)
            % irisinp.model( ) - model with any number of parameterizations.
            % irisinp.model(1) - model with single parameterization.
            if nargin==0
                MaxNAlt = Inf;
            end
            if MaxNAlt==1
                this.ReportName = [ ...
                    this.ReportName, ...
                    ' with Single Parameterization', ...
                    ];
            end
            validFn = this.ValidFn;
            this.ValidFn = @(x) validFn(x) && length(x)<=MaxNAlt;
        end
    end
end
