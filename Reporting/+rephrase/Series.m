classdef Series ...
    < rephrase.Element ...
    & rephrase.Terminus ...
    & rephrase.Data

    properties (Constant)
        Type = rephrase.Type.SERIES
    end


    methods
        function this = Series(title, input, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = input;
        end%


        function build(this, varargin)
            this.Content = buildSeriesData(this, this.Content);
        end%
    end
end 
