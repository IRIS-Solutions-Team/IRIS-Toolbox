classdef dbaseOptional < irisinp.dbase   
    methods
        function this = dbaseOptional(varargin)
            this = this@irisinp.dbase(varargin{:});
            this.ReportName = ['Optional ',this.ReportName];
            this.Omitted = [ ];
            validFn = this.ValidFn;
            this.ValidFn = @(x) validFn(x) || isequal(x,[ ]);
        end
    end
end
