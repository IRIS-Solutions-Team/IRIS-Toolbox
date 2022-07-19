classdef Series ...
    < rephrase.Terminal ...
    & rephrase.DataMixin ...
    & rephrase.ColorMixin

    properties % (Constant)
        Type = rephrase.Type.SERIES
    end


    properties (Hidden)
        Settings_LineWidth (1, 1) double {mustBeNonnegative} = 2
        Settings_ShowLegend (1, 1) logical = true
        Settings_Type (1, 1) string = "scatter"
        Settings_Markers (1, 1) struct = struct("Color", NaN, "Symbol", "circle", "Size", 6) 
        Settings_StackGroup (1, 1) string = ""
        Settings_Fill (1, 1) string = "none"
        Settings_Units (1, 1) string = ""
    end


    methods
        function this = Series(title, input, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Content = input;
        end%


        function this = finalize(this, varargin)
            finalize@rephrase.Terminal(this);
            this.Content = finalizeSeriesData(this, this.Content);
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
