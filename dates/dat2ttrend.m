% dat2ttrend  Construct linear time trend from date range
%
% __Syntax__
%
%     [trend, baseDate] = dat2ttrend(range)
%     [trend, baseDate] = dat2ttrend(range, baseYear)
%     [trend, baseDate] = dat2ttrend(range, obj)
%
%
% __Input Arguments__
%
% * `range` [ numeric ] - Date range from which an integer linear time
% trend will be constructed.
%
% * `baseYear` [ model | VAR ] - Base year that will be used to construct
% the time trend.
%
% * `obj` [ model | VAR ] - Model or VAR object whose base year will be
% used to construct the time trend; if both `BaseYear` and `Obj` are
% omitted, the base year from `iris.get('baseYear')` will be used.
%
%
% __Output Arguments__
%
% * `trend` [ numeric ] - Integer linear time trend, unique to the input
% date range `Range` and the base year.
%
% * `baseDate` [ numeric ] - Base date used to normalize the input date
% range; see Description.
%
%
% __Description__
%
% For regular date frequencies, the time trend is constructed the following
% way. First, a base date is created first period in the base year of a
% given frequency. For instance, for a quarterly input range,
% `BaseDate=qq(baseYear,1)`, for a monthly input range,
% `BaseDate=mm(baseYear,1)`, etc. Then, the output trend is an integer
% vector normalized to the base date,
%
%     TTrend = round(Range - BaseDate);
%
% For indeterminate date frequencies, `BaseDate=0`, and the output
% time trend is simply the input date range.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [trend, baseYear] = dat2ttrend(range, baseYear)

DATECODE_TOLERANCE = 0.001;

try
    if ~isnumeric(baseYear)
        baseYear = get(baseYear, 'baseYear');
    end
catch
    baseYear = @auto;
end

if ~isnumeric(baseYear)
    baseYear = iris.get('baseYear');
end

if isempty(range)
    trend = double(range);
else
    freq = dater.getFrequency(range);
    Frequency.checkMixedFrequency(freq);
    freq = freq(1);
    if freq==0
        trend = double(range);
        baseYear = 0;
    elseif freq==365
        baseDate = dater.dd(baseYear, 1, 1);
        trend = double(range) - baseDate;
    else
        baseDate = dater.datecode(freq, baseYear, 1);
        trend = double(range) - baseDate;
    end
end

trend0 = trend;
trend = round(trend);
if any(abs(trend0-trend)>DATECODE_TOLERANCE)
    throw( exception.Base('Dates:FrequencyMismatch', 'error') );
end

end%

