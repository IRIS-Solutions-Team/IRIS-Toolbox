classdef listOptional < irisinp.list
    methods
        function this = listOptional(varargin)
            this = this@irisinp.list(varargin{:});
            this.ReportName = ['Optional ',this.ReportName];
            this.Omitted = { };
        end
    end
end
