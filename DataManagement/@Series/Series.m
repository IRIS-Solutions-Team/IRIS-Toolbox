classdef (InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper}) ...
        Series < tseries

    properties (Dependent)
    end


    methods
        function this = Series(varargin)
            this = this@tseries(varargin{:});
            this.Start = DateWrapper(this.Start);
        end
    end


    methods
        function varargout = plot(varargin)
            [varargout{1:nargout}] = plot@TimeSeriesBase(varargin{:});
        end
    end


    methods (Static)
        varargout = fromFred(varargin)
        varargout = linearTrend(varargin)
        varargout = empty(varargin)
    end
end
