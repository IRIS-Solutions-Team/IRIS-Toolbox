function [xData, positionWithinPeriod, dateFormat] = createDateAxisData( axesHandle, ...
                                                                         time, ...
                                                                         positionWithinPeriod, ...
                                                                         dateFormat )

if nargin<3
    positionWithinPeriod = @auto;
end

if nargin<4
    dateFormat = @config;
end

%-------------------------------------------------------------------------------

positionWithinPeriod = hereResolvePositionWithinPeriod(axesHandle, positionWithinPeriod);

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
    if isequal(dateFormat, @config) || isequal(dateFormat, @default)
        temp = iris.get('PlotDateTimeFormat');
        nameOfFreq = Frequency.toChar(timeFrequency);
        dateFormat = temp.(nameOfFreq);
    end
    dateFormat = backwardCompatibilityDateFormat(dateFormat, timeFrequency);
    try
        xData.Format = dateFormat;
    end
    try
        axesHandle.XAxis.TickLabelFormat = dateFormat;
    end
end

end%

%
% Local Functions
%

function positionWithinPeriod = hereResolvePositionWithinPeriod(axesHandle, positionWithinPeriod)
    axesPositionWithinPeriod = getappdata(axesHandle, 'IRIS_PositionWithinPeriod');
    if isempty(axesPositionWithinPeriod) 
        if isequal(positionWithinPeriod, @auto)
            positionWithinPeriod = 'Start';
        end
    else
        if isequal(positionWithinPeriod, @auto)
            positionWithinPeriod = axesPositionWithinPeriod;
        elseif ~isequal(axesPositionWithinPeriod, positionWithinPeriod)
            warning( 'TimeSubscriptable:DifferentPositionWithinPeriod', ...
                     'Option PositionWithinPeriod= differs from the value set in the current Axes.' );
        end
    end
end%




function dateFormat = backwardCompatibilityDateFormat(dateFormat, timeFrequency)
    if strcmp(dateFormat, 'YYYY')
        dateFormat = 'uuuu';
        return
    end
    if strcmp(dateFormat, 'YYYYFP')
        if timeFrequency==Frequency.YEARLY
            dateFormat = 'uuuu''Y''';
        elseif timeFrequency==Frequency.HALFYEARLY
            dateFormat = 'uuuu''H''MM';
        elseif timeFrequency==Frequency.QUARTERLY
            dateFormat = 'uuuuQQQ';
        elseif timeFrequency==Frequency.MONTHLY
            dateFormat = 'uuuu''M''MM';
        end
        return
    end
    if strcmp(dateFormat, 'YYYYF')
        if timeFrequency==Frequency.YEARLY
            dateFormat = 'uuuu''Y''';
        elseif timeFrequency==Frequency.HALFYEARLY
            dateFormat = 'uuuu''H''';
        elseif timeFrequency==Frequency.QUARTERLY
            dateFormat = 'uuuu''Q''';
        elseif timeFrequency==Frequency.MONTHLY
            dateFormat = 'uuuu''M''';
        end
        return
    end
    if strcmp(dateFormat, 'YY:P')
        if timeFrequency==Frequency.YEARLY
            dateFormat = 'yy:';
        elseif timeFrequency==Frequency.HALFYEARLY
            dateFormat = 'yy:MM';
        elseif timeFrequency==Frequency.QUARTERLY
            dateFormat = 'yy:Q';
        elseif timeFrequency==Frequency.MONTHLY
            dateFormat = 'yy:MM';
        end
        return
    end
    if strcmp(dateFormat, 'YY:MM')
        if timeFrequency==Frequency.MONTHLY
            dateFormat = 'yy''M''MM';
        end
        return
    end
end%

