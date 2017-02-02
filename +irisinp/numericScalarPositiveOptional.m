classdef numericScalarPositiveOptional < irisinp.numericScalarPositive
    methods
        function this = numericScalarPositiveOptional(varargin)
            this = this@irisinp.numericScalarPositive(varargin{:});
            this.ReportName = ['Optional ',this.ReportName];
            this.Omitted = [ ];
            validFn = this.ValidFn;
            this.ValidFn = @(x) validFn(x) || isequal(x,[ ]);
        end
    end
end