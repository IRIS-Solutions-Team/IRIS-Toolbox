function [trend, baseYear] = dat2ttrend(range, baseYear)
% dat2ttrend  Construct linear time trend from date range.
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

try
    if ~isintscalar(baseYear)
        baseYear = get(baseYear, 'baseYear');
    end
catch
    baseYear = @config;
end

%--------------------------------------------------------------------------

if ~isintscalar(baseYear)
    baseYear = iris.get('baseYear');
end

if isempty(range)
    trend = range;
else
    freq = DateWrapper.getFrequencyFromNumeric(range);
    DateWrapper.checkMixedFrequency(freq);
    freq = freq(1);
    if freq==0
        trend = range;
        baseYear = 0;
    elseif freq==365
        baseDate = dd(baseYear, 1, 1);
        trend = round(range - baseDate);
    else
        baseDate = datcode(freq, baseYear, 1);
        trend = round(range - baseDate);
    end
end

end
