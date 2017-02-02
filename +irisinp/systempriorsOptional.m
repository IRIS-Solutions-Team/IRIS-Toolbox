classdef systempriorsOptional < irisinp.systempriors
    methods
        function this = systempriorsOptional(varargin)
            this = this@irisinp.systempriors(varargin{:});
            this.ReportName = 'System Priors';
            this.Omitted = [ ];
            this.ValidFn = @(x) isempty(x) || isa(x,'systempriors');
        end
    end
end
