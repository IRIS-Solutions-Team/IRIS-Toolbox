
function [xData, positionWithinPeriod, dateFormat] = createDateAxisData(axesHandle, time, positionWithinPeriod, dateFormat)

if nargin<3
    positionWithinPeriod = @auto;
end

if nargin<4
    dateFormat = @auto;
end


    positionWithinPeriod = local_resolvePositionWithinPeriod(axesHandle, positionWithinPeriod);

    if ~isempty(time)
        timeFrequency = dater.getFrequency(time(1));
    else
        timeFrequency = NaN;
    end

    if isempty(time)
        xData = datetime.empty(size(time));
        return
    end

    if timeFrequency==Frequency.INTEGER
        xData = dater.getSerial(time);
    else
        xData = dater.toMatlab(time, lower(positionWithinPeriod));
        if isequal(dateFormat, @auto)
            temp = iris.get('PlotDateTimeFormat');
            dateFormat = temp.(Frequency.toChar(timeFrequency));
        end
        dateFormat = local_backwardCompatibilityDateFormat(dateFormat, timeFrequency);
        try
            xData.Format = dateFormat;
        end
    end

end%


function positionWithinPeriod = local_resolvePositionWithinPeriod(axesHandle, positionWithinPeriod)
    %(
    axesPositionWithinPeriod = getappdata(axesHandle, 'IRIS_PositionWithinPeriod');
    if isempty(axesPositionWithinPeriod) 
        if isequal(positionWithinPeriod, @auto)
            positionWithinPeriod = 'Start';
        end
    else
        if isequal(positionWithinPeriod, @auto)
            positionWithinPeriod = axesPositionWithinPeriod;
        elseif ~isequal(axesPositionWithinPeriod, positionWithinPeriod)
            warning( 'Series:DifferentPositionWithinPeriod', ...
                     'Option PositionWithinPeriod= differs from the value set in the current Axes.' );
        end
    end
    %)
end%


function dateFormat = local_backwardCompatibilityDateFormat(dateFormat, timeFrequency)
    %(
    dateFormat = string(dateFormat);
    if contains(dateFormat, "YYYY", "IgnoreCase", true)
        dateFormat = replace(dateFormat, "YYYY", "uuuu");
    end

    if contains(dateFormat, "uuuuFP")
        replacement = [ ];
        if timeFrequency==Frequency.YEARLY
            replacement = "uuuu'Y'";
        elseif timeFrequency==Frequency.HALFYEARLY || timeFrequency==Frequency.MONTHLY
            replacement = "uuuu'M'MM";
        elseif timeFrequency==Frequency.QUARTERLY
            replacement = "uuuuQQQ";
        end
        if ~isempty(replacement)
            dateFormat = replace(dateFormat, "uuuuFP", replacement);
        end
    end

    if contains(dateFormat, "uuuu:P")
        replacement = [ ];
        if timeFrequency==Frequency.YEARLY
            replacement = "uuuu";
        elseif timeFrequency==Frequency.HALFYEARLY || timeFrequency==Frequency.MONTHLY
            replacement = "uuuu:MM";
        elseif timeFrequency==Frequency.QUARTERLY
            dateFormat = "uuuu:Q";
        end
        if ~isempty(replacement)
            dateFormat = replace(dateFormat, "uuuu:P", replacement);
        end
    end

    dateFormat = replace(dateFormat, "YY", "yy");
    if contains(dateFormat, "yy:P")
        replacement = [ ];
        if timeFrequency==Frequency.YEARLY
            dateFormat = "yy";
        elseif timeFrequency==Frequency.HALFYEARLY || timeFrequency==Frequency.MONTHLY
            dateFormat = "yy:MM";
        elseif timeFrequency==Frequency.QUARTERLY
            dateFormat = "yy:Q";
        end
        if ~isempty(replacement)
            dateFormat = replace(dateFormat, "yy:P", replacement);
        end
    end
    %)
end%

