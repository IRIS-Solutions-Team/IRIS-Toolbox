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
freq = dater.getFrequency(dateCode);
serial = dater.getSerial(dateCode);

inxInteger = freq==double(Frequency.INTEGER);
inxWeekly  = freq==double(Frequency.WEEKLY);
inxDaily   = freq==double(Frequency.DAILY);
inxRegular = ~inxInteger & ~inxWeekly & ~inxDaily;

year = nan(size(dateCode));
if nargout>=2
    per = nan(size(dateCode));
end

%
% Regular frequencies
%
if any(inxRegular)
    year(inxRegular) = floor( double(serial(inxRegular)) ./ double(freq(inxRegular)) );
    if nargout>=2
        per(inxRegular) = round(serial(inxRegular) - year(inxRegular).*freq(inxRegular) + 1);
    end
end

%
% Integer frequency
%
if any(inxInteger)
    year(inxInteger) = NaN;
    if nargout>=2
        per(inxInteger) = serial(inxInteger);
    end
end

%
% Daily frequency
%
if any(inxDaily)
    [year(inxDaily), ~] = datevec(dateCode(inxDaily));
    if nargout>=2
        startYear = datenum(year(inxDaily), 1, 1);
        per(inxDaily) = round(serial(inxDaily) - startYear + 1);
    end
end

%
% Weekly frequency
%
if any(inxWeekly)
    x = ww2day(serial(inxWeekly));
    if nargout>=2
        [year(inxWeekly), per(inxWeekly)] = day2ypfweekly(x);
    else
        year(inxWeekly) = day2ypfweekly(x);
    end
end

end%

