classdef mlistOptional < irisinp.mlist
    methods
        function this = mlistOptional(varargin)
            this = this@irisinp.mlist(varargin{:});
            this.ReportName = ['Optional ',this.ReportName];
            this.Omitted = @all;
        end
    end
end
