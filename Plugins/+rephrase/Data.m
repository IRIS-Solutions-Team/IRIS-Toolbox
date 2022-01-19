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
            elseif any(parent.Type==[rephrase.Type.TABLE, rephrase.Type.DIFFTABLE])
                dates = locallyReadDates(freq, parent.Settings.Dates);
                values = getData(input, dates);
                dates = NaN;
            else
                exception.error("Internal", "Invalid parent of SERIES element");
            end
            values = values(:, 1);
            output = struct();
            output.Dates = dates; %DateWrapper(dates);
            output.Values = reshape(values, 1, [ ]);
        end%


        function output = buildCurveData(this, input)
            if isstring(input) || ischar(input)
                output = string(input);
                this.DataRequests = [this.DataRequests, output];
                return
            end
            minTick = min(this.Parent.Settings.Ticks);
            maxTick = max(this.Parent.Settings.Ticks);
            tickIndex = input.Ticks >= minTick & input.Ticks <= maxTick;
            output = struct( );
            output.Ticks = reshape(input.Ticks(tickIndex), 1, [ ]);
            output.Values = reshape(input.Values(tickIndex), 1, [ ]);
        end%
    end
end


function dates = locallyReadDates(freq, dates)
    if isnumeric(dates)
        return
    end
    dates = dater.fromIsoString(freq, dates);
end%

