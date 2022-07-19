classdef DiffSeries ...
    < rephrase.Terminal ...
    & rephrase.DataMixin

    properties % (Constant)
        Type = rephrase.Type.DIFFSERIES
    end


    properties (Hidden)
        Settings_Units (1, 1) string = ""
    end


    methods
        function this = DiffSeries(title, baseline, alternative, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Content = {baseline, alternative};
        end%


        function finalize(this, varargin)
            finalize@rephrase.Terminal(this);
            this.Content{1} = finalizeSeriesData(this, this.Content{1});
            this.Content{2} = finalizeSeriesData(this, this.Content{2});
        end%
    end
end 

