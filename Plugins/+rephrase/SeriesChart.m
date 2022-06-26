classdef SeriesChart ...
    < rephrase.Container ...
    & rephrase.ChartMixin

    properties
        Type = rephrase.Type.SERIESCHART
    end


    properties (Hidden)
        Settings_StartDate (1, 1) string
        Settings_EndDate (1, 1) string
        Settings_DateFormat (1, 1) string = "YYYY-MM-DD"
        Settings_ShowLegend (1, 1) logical = true
        Settings_Highlight = cell.empty(1, 0)
    end


    properties (Constant, Hidden)
        PossibleChildren = [ 
            rephrase.Type.SERIES
        ]
    end


    methods
        function this = SeriesChart(title, dates, varargin)
% >=R2019b
%(
            arguments
                title (1, :) string
                dates (1, :) double
            end

            arguments (Repeating)
                varargin
            end
%)
% >=R2019b

            [startDate, endDate, varargin] = local_parseInputDates(dates, varargin);

            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);

            this.Settings_StartDate = dater.toIsoString(double(startDate), "start");
            this.Settings_EndDate = dater.toIsoString(double(endDate), "end");
        end%


        function this = set.Settings_Highlight(this, x)
            if ~iscell(x)
                x = {x};
            end
            this.Settings_Highlight = x;
        end%
    end


    methods (Static)
        function this = fromSeries(chartInputs, varargin)
            this = rephrase.SeriesChart(chartInputs{:});
            for i = 1 : numel(varargin)
                series = rephrase.Series.fromMultivariate(varargin{i}{:});
                add(this, series);
            end
        end%
    end
end 

%
% Local functions
%


function [startDate, endDate, repeating] = local_parseInputDates(dates, repeating)
    %(
    dates = double(dates);
    if isempty(repeating) || ~isnumeric(repeating{1}) || isempty(repeating{1})
        startDate = dates(1);
        endDate = dates(end);
    else
        startDate = dates(1);
        endDate = double(repeating{1});
        endDate = endDate(end);
        repeating(1) = [];
    end
    %)
end%


