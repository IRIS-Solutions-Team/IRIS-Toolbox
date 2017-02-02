classdef tseriesOptional < irisinp.tseries
    methods
        function this = tseriesOptional(varargin)
            this.ReportName = 'Optional Time Series';
            this.Omitted = [ ];
        end
    end
end
