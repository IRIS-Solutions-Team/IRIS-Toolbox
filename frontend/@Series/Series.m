classdef (InferiorClasses={?matlab.graphics.axis.Axes, ?dates.Date}) ...
        Series < tseries
    methods
        function this = Series(varargin)
            this = this@tseries(varargin{:});
        end
    end
end
