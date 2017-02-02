classdef modelOptional < irisinp.model
    methods
        function this = modelOptional(varargin)
            this = this@irisinp.model(varargin{:});
            this.ReportName = ['Optional ',this.ReportName];
            this.Omitted = [ ];
            validFn = this.ValidFn;
            this.ValidFn = @(x) validFn(x) || isequal(x,[ ]);
        end
    end
end
