classdef DiffSeries ...
    < rephrase.Element ...
    & rephrase.Terminus ...
    & rephrase.Data

    properties (Constant)
        Type = rephrase.Type.DIFFSERIES
    end


    methods
        function this = DiffSeries(title, baseline, alternative, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = {baseline, alternative};
        end%


        function build(this, varargin)
            this.Content{1} = buildSeriesData(this, this.Content{1});
            this.Content{2} = buildSeriesData(this, this.Content{2});
        end%
    end
end 
