classdef (Abstract) DataMixin ...
    < matlab.mixin.Copyable

    properties (Hidden)
        Settings_Conditional 
        Settings_Transform = []
        Settings_Round (1, 1) double = Inf
    end


    methods 
        function output = finalizeSeriesData(this, input)
            %(
            % Keep expression string and add to the data requests
            if isstring(input) || ischar(input)
                output = textual.stringify(input);
                this.DataRequests = union(this.DataRequests, output, 'stable');
                return
            end

            % Convert input time series to Dates/Values
            if isa(input, 'Series')
                parent = this.Parent;
                input = transform(this, input);
                if rephrase.Type.isChart(parent.Type)
                    [dates, values] = this.finalizeForChart(input, parent.Settings_StartDate, parent.Settings_EndDate);
                else
                    [dates, values] = this.finalizeForTable(input, parent.Settings_Dates);
                end
                values = round(this, values);
                output = struct();
                output.Dates = dates;
                output.Values = reshape(values, 1, []);
                return
            end

            % Content already finalized
            if isstruct(input) && isfield(input, 'Dates') && isfield(input, 'Values')
                output = input;
                return
            end
            %)
        end%


        function values = round(this, values)
            %(
            if this.Settings_Round<Inf
                values = round(values, round(this.Settings_Round));
            end
            %)
        end%


        function input = transform(this, input)
            if isa(this.Settings.Transform, 'function_handle')
                input = this.Settings.Transform(input);
            end
            this.Settings.Transform = [];
        end%
    end


    methods (Static)
        function [dates, values] = finalizeForChart(inputSeries, startDate, endDate)
            freq = getFrequency(inputSeries);
            [values, ~, ~, dates] = getDataFromTo(inputSeries, startDate, endDate);
            dates = reshape(dates, [], 1);
            values = values(:, 1);
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
            if freq>0
                dates = textual.stringify(dater.toIsoString(dates, "start"));
            end
        end%


        function [dates, values] = finalizeForTable(inputSeries, dates)
            values = getData(inputSeries, dates);
            values = values(:, 1);
            dates = [];
        end%
    end
end

