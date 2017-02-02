classdef rangeProper < irisinp.range
    methods
        function this = rangeProper(varargin)
            this.ReportName = ['Proper ',this.ReportName];
            this.ValidFn = @(x) isdatrangeproper(x);
        end
    end
end
