classdef rangeProper < irisinp.range
    methods
        function this = rangeProper(varargin)
            this.ReportName = ['Proper ',this.ReportName];
            this.ValidFn = @DateWrapper.validateProperRangeInput;
        end
    end
end
