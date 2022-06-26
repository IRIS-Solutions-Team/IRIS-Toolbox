classdef (Abstract) DataMixin ...
    < matlab.mixin.Copyable

    methods 
        function output = finalizeSeriesData(this, input)
            % Keep expression string and add to the data requests
            if isstring(input) || ischar(input)
                output = string(input);
                this.DataRequests = union(this.DataRequests, output, 'stable');
                return
            end

            % Convert input time series to Dates/Values
            if isa(input, 'Series')
                parent = this.Parent;
                freq = input.Frequency;
                if ismember(parent.Type, [rephrase.Type.CHART, rephrase.Type.SERIESCHART, rephrase.Type.CURVECHART])
                    startDate = dater.fromIsoString(freq, parent.Settings_StartDate);
                    endDate = dater.fromIsoString(freq, parent.Settings_EndDate);
                    values = getDataFromTo(input, startDate, endDate);
                    dates = dater.colon(startDate, endDate);
                    dates = dater.toIsoString(dates, "mid");
                else
                    dates = dater.fromIsoString(freq, parent.Settings_Dates);
                    values = getData(input, dates);
                    dates = NaN;
                end

                values = values(:, 1);
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
        end%
    end
end

