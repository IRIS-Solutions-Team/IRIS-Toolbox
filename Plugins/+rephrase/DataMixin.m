classdef (Abstract) DataMixin ...
    < matlab.mixin.Copyable

    properties (Hidden)
        Settings_Conditional 
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
                freq = input.Frequency;
                if ismember(string(parent.Type), [string(rephrase.Type.CHART), string(rephrase.Type.SERIESCHART), string(rephrase.Type.CURVECHART)])
                    startDate = parent.Settings_StartDate;
                    endDate = parent.Settings_EndDate;
                    values = getDataFromTo(input, startDate, endDate);
                    dates = dater.colon(startDate, endDate);
                    if freq>0
                        dates = dater.toIsoString(dates, "start");
                    end
                else
                    dates = parent.Settings_Dates;
                    values = getData(input, dates);
                    dates = NaN;
                end

                values = values(:, 1);
                output = struct();
                output.Dates = dates;
                if this.Settings_Round<Inf
                    values = round(values, round(this.Settings_Round));
                end
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
    end
end

