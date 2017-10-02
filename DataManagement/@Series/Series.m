classdef (InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper}) ...
        Series < tseries

    properties (Dependent)
        End
        Range
    end


    methods
        function this = Series(varargin)
            this = this@tseries(varargin{:});
            this.Start = DateWrapper(this.Start);
        end


        function end_ = get.End(this)
            end_ = this.Start + size(this.Data, 1) - 1;
        end


        function range = get.Range(this)
            range = (this.Start : this.End).';
        end
    end


    methods (Static)
        varargout = fromFred(varargin)
        varargout = linearTrend(varargin)
    end
end
