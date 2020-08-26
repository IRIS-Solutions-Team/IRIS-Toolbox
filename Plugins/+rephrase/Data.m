classdef (Abstract) Data ...
    < matlab.mixin.Copyable

    methods 
        function output = buildSeriesData(this, input)
            if isstring(input) || ischar(input)
                output = string(input);
                this.DataRequests = [this.DataRequests, output];
                return
            end
            freq = input.Frequency;
            parent = this.Parent;
            if parent.Type==rephrase.Type.CHART
                startDate = locallyReadDates(freq, parent.Settings.StartDate);
                endDate = locallyReadDates(freq, parent.Settings.EndDate);
                values = getDataFromTo(input, startDate, endDate);
                dates = dater.colon(startDate, endDate);
                dates = dater.toIsoString(dates, "m");
            else
                dates = locallyReadDates(freq, parent.Settings.Dates);
                values = getData(input, dates);
                dates = NaN;
            end
            values = values(:, 1);
            output = struct( );
            output.Dates = DateWrapper(dates);
            output.Values = reshape(values, 1, [ ]);
        end%
    end
end


function dates = locallyReadDates(freq, dates)
    if isnumeric(dates)
        return
    end
    dates = dater.fromIsoString(freq, dates);
end%

