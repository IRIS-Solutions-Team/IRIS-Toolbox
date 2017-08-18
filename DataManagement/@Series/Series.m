classdef (InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper}) ...
        Series < tseries
    properties (Constant)
        MissingValue = NaN;
        MissingTest = @isnan;
    end


    properties (Dependent)
        Frequency
        End
        Range
    end


    methods
        function this = Series(varargin)
            this = this@tseries(varargin{:});
            this.Start = DateWrapper(this.Start);
        end


        function frequency = get.Frequency(this)
            frequency = getFrequency(this.Start);
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
    end
end
