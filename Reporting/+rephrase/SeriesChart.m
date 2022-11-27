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


        function out = getFinalDates(this)
            startDate = double(this.Settings_StartDate);
            endDate = double(this.Settings_EndDate);
            out = dater.colon(startDate, endDate);
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


        function content = finalizeSeriesData(content)
            values = content.Values;
            dates = content.Dates;
            values = reshape(values, [], 1);
            dates = reshape(dates, [], 1);
            inxData = ~isnan(values);
            posFirst = find(inxData, 1, 'first');
            posLast = find(inxData, 1, 'last');
            if ~isempty(posFirst)
                values = values(posFirst:posLast, :);
                dates = dates(posFirst:posLast, :);
            else
                values = values([], :);
                dates = dates([], :);
            end
            if isnumeric(dates) && ~isempty(dates)
                freq = dater.getFrequency(dates(1));
                if freq>0
                    dates = textual.stringify(dater.toIsoString(dates, "start"));
                end
            end
            content.Values = values;
            content.Dates = dates;
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


