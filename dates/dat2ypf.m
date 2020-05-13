function [year, per, freq, doy] = dat2ypf(dateCode)
% dat2ypf  Convert IRIS serial date number to year, period and frequency
%{
% ## Syntax ##
%
%     [year, period, freq] = dat2ypf(dateCode)
%
%
% ## Input Arguments ##
%
% __`dateCode`__ [ DateWrapper | numeric ] -
% IRIS dates or IRIS numeric date codes that will be converted to a year, 
% period and frequency.
%
%
% ## Output Arguments ##
%
% __`year`__ [ numeric ] -
% Year.
%
% __`period`__ [ numeric ] -
% Period within year.
%
% __`freq`__ [ numeric ] -
% Date frequency.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = double(dateCode);
freq = DateWrapper.getFrequencyAsNumeric(dateCode);
serial = DateWrapper.getSerial(dateCode);

inxInteger = freq==double(Frequency.INTEGER);
inxWeekly  = freq==double(Frequency.WEEKLY);
inxDaily   = freq==double(Frequency.DAILY);
inxRegular = ~inxInteger & ~inxWeekly & ~inxDaily;

year = nan(size(dateCode));
per = nan(size(dateCode));

%
% Regular frequencies
%
if any(inxRegular)
    year(inxRegular) = floor( double(serial(inxRegular)) ./ double(freq(inxRegular)) );
    per(inxRegular) = round(serial(inxRegular) - year(inxRegular).*freq(inxRegular) + 1);
end

%
% Integer frequency
%
if any(inxInteger)
    year(inxInteger) = NaN;
    per(inxInteger) = serial(inxInteger);
end

%
% Daily frequency
%
if any(inxDaily)
    [year(inxDaily), ~] = datevec(dateCode(inxDaily));
    startYear = datenum(year(inxDaily), 1, 1);
    per(inxDaily) = round(serial(inxDaily) - startYear + 1);
end

%
% Weekly frequency
%
if any(inxWeekly)
    x = ww2day(serial(inxWeekly));
    [year(inxWeekly), per(inxWeekly)] = day2ypfweekly(x);
end

end%

