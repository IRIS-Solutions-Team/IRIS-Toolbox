classdef SeriesChart ...
    < rephrase.Container ...
    & rephrase.ChartMixin

    properties
        Type = string(rephrase.Type.SERIESCHART)
    end


    properties (Hidden)
        Settings_StartDate (1, 1) 
        Settings_EndDate (1, 1)
        Settings_DateFormat (1, 1) string = "YYYY-MM-DD"
        Settings_BarMode (1, 1) string = "group"
        Settings_Frequency (1, 1) double = NaN
    end


    properties (Constant, Hidden)
        PossibleChildren = [ 
            string(rephrase.Type.SERIES)
        ]
    end


    methods
        function this = SeriesChart(title, dates, varargin)
% >=R2019b
%{
            arguments
                title (1, :) string
                dates (1, :) double
            end

            arguments (Repeating)
                varargin
            end
%}
% >=R2019b

            [freq, startDate, endDate, varargin] = local_parseInputDates(dates, varargin);
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
            this.Settings_Frequency = freq;
            this.Settings_StartDate = startDate;
            this.Settings_EndDate = endDate;
        end%


        function finalize(this, counter)
            finalize@rephrase.Container(this, counter);
            this.Settings.StartDate = this.resolveStartDate(this.Settings_StartDate);
            this.Settings.EndDate = this.resolveEndDate(this.Settings_EndDate);
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


        function date = resolveStartDate(date)
            if dater.getFrequency(date)>0
                date = dater.toIsoString(double(date-1), "mid");
            else
                date = double(date) - 0.5;
            end
        end%


        function date = resolveEndDate(date)
            if dater.getFrequency(date)>0
                date = dater.toIsoString(double(date), "mid");
            else
                date = double(date) + 0.5;
            end
        end%
    end
end 

%
% Local functions
%


function [freq, startDate, endDate, repeating] = local_parseInputDates(dates, repeating)
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
    freq = dater.getFrequency(startDate);
    %)
end%


