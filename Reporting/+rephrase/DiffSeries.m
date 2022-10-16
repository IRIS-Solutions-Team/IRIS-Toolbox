classdef DiffSeries ...
    < rephrase.Terminal ...
    & rephrase.DataMixin

    properties % (Constant)
        Type = string(rephrase.Type.DIFFSERIES)
    end


    properties (Hidden)
        Settings_Units (1, 1) string = ""
        Baseline = cell.empty(1, 0)
        Alternative = cell.empty(1, 0)
    end


    methods
        function this = DiffSeries(title, baseline, alternative, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Baseline = baseline;
            this.Alternative = alternative;
        end%


        function finalize(this, varargin)
            finalize@rephrase.Terminal(this);
            this.Content = { ...
                finalizeSeriesData(this, this.Baseline) ...
                , finalizeSeriesData(this, this.Alternative) ...
            };
        end%
    end
end 

