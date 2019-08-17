function [year, per, freq] = dat2ypf(dat)
% dat2ypf  Convert IRIS serial date number to year, period and frequency.
%
% Syntax
% =======
%
%     [Y,P,F] = dat2ypf(Dat)
%
% Input arguments
% ================
%
% * `Dat` [ numeric ] - IRIS serial date numbers.
%
% Output arguments
% =================
%
% * `Y` [ numeric ] - Years.
%
% * `P` [ numeric ] - Periods within year.
%
% * `F` [ numeric ] - Date frequencies.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

dat = double(dat);
freq = DateWrapper.getFrequencyAsNumeric(dat);
serial = DateWrapper.getSerial(dat);

inxOfZero    = freq==0;
inxOfWeekly  = freq==52;
inxOfDaily   = freq==365;
inxOfRegular = ~inxOfZero & ~inxOfWeekly & ~inxOfDaily;

[year,per] = deal(nan(size(dat)));

% Regular frequencies
if any(inxOfRegular)
    year(inxOfRegular) = floor( double(serial(inxOfRegular)) ./ double(freq(inxOfRegular)) );
    per(inxOfRegular) = round(serial(inxOfRegular) - year(inxOfRegular).*freq(inxOfRegular) + 1);
end

% Integer frequency
if any(inxOfZero)
    year(inxOfZero) = NaN;
    per(inxOfZero) = serial(inxOfZero);
end

% Daily frequency; dat2ypf not applicable
if any(inxOfDaily)
    year(inxOfDaily) = NaN;
    per(inxOfDaily) = serial(inxOfDaily);
end

% Weekly frequency
if any(inxOfWeekly)
    x = ww2day(serial(inxOfWeekly));
    [year(inxOfWeekly), per(inxOfWeekly)] = day2ypfweekly(x);
end

end%

