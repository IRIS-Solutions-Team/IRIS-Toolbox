classdef (Abstract) DataMixin ...
    < matlab.mixin.Copyable

    properties (Hidden)
        Settings_Conditional 
        Round (1, 1) double = Inf
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
                if rephrase.Type.isChart(parent.Type)
                    [dates, values] = this.finalizeForChart(input, parent.Settings_StartDate, parent.Settings_EndDate);
                else
                    [dates, values] = this.finalizeForTable(input, parent.Settings_Dates);
                end
                values = values(:, 1);
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
            if this.Round<Inf
                values = round(values, round(this.Round));
            end
            %)
        end%
    end


    methods (Static)
        function [dates, values] = finalizeForChart(inputSeries, startDate, endDate)
            freq = getFrequency(inputSeries);
            [values, ~, ~, dates] = getDataFromTo(inputSeries, startDate, endDate);
            if freq>0
                dates = dater.toIsoString(dates, "start");
            end
        end%


        function [dates, values] = finalizeForTable(inputSeries, dates)
            values = getData(inputSeries, dates);
            dates = NaN;
        end%
    end
end

