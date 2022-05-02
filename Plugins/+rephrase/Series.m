classdef Series ...
    < rephrase.Element ...
    & rephrase.Terminus ...
    & rephrase.Data

    properties % (Constant)
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


    methods (Static)
        function these = fromMultivariate(titles, inputs, varargin)
            titles = textual.stringify(titles);
            numTitles = numel(titles);
            inputs.Data = inputs.Data(:, :);
            numSeries = size(inputs.Data, 2);
            these = rephrase.Series.empty(1, 0);
            if isempty(titles)
                titles = repmat("", 1, numSeries);
            elseif numTitles==1 && numSeries>1
                titles = repmat(titles, 1, numSeries);
            end
            for i = 1 : numSeries
                these(end+1) = rephrase.Series(titles(i), inputs{:, i}, varargin{:});
            end
        end%
    end
end 
