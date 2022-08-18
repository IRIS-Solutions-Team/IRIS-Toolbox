% getYearPeriodFrequency  Break IrisT date code into year, period and frequency
%{
% Syntax
%--------------------------------------------------------------------------
%
%     [year, period, freq] = dat2ypf(dateCode)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`dateCode`__ [ Dater | numeric ] 
%
% IRIS dates or IRIS numeric date codes that will be converted to a year, 
% period and frequency.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`year`__ [ numeric ] 
%
%>    Calendar year.
%
%u
% __`period`__ [ numeric ] 
%
%>    Period within year.
%
%
% __`freq`__ [ numeric ] 
%
%>    Date frequency.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [year, per, freq] = getYearPeriodFrequency(dateCode)

dateCode = double(dateCode);
freq = dater.getFrequency(dateCode);
serial = dater.getSerial(dateCode);

inxInteger = freq==double(Frequency.INTEGER);
inxWeekly = freq==double(Frequency.WEEKLY);
inxDaily = freq==double(Frequency.DAILY);
inxRegular = ~inxInteger & ~inxWeekly & ~inxDaily;

year = nan(size(dateCode));
returnPeriod = nargout>=2;;
if returnPeriod
    per = nan(size(dateCode));
end

%
% Regular frequencies
%
if any(inxRegular)
    year(inxRegular) = floor( double(serial(inxRegular)) ./ double(freq(inxRegular)) );
    if returnPeriod
        per(inxRegular) = round(serial(inxRegular) - year(inxRegular).*freq(inxRegular) + 1);
    end
end

%
% Integer frequency
%
if any(inxInteger)
    year(inxInteger) = NaN;
    if returnPeriod
        per(inxInteger) = serial(inxInteger);
    end
end

%
% Daily frequency
%
if any(inxDaily)
    [year(inxDaily), ~] = datevec(dateCode(inxDaily));
    if returnPeriod
        startYear = datenum(year(inxDaily), 1, 1);
        per(inxDaily) = round(serial(inxDaily) - startYear + 1);
    end
end

%
% Weekly frequency
%
if any(inxWeekly)
    x = ww2day(serial(inxWeekly));
    if returnPeriod
        [year(inxWeekly), per(inxWeekly)] = day2ypfweekly(x);
    else
        year(inxWeekly) = day2ypfweekly(x);
    end
end

end%

