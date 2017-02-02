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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

freq = double(datfreq(dat));
serial = double(floor(dat));
ixZero = freq==0;
ixWeekly = freq==52;
ixDaily = freq==365;
ixReg = ~ixZero & ~ixWeekly & ~ixDaily;

[year,per] = deal(nan(size(dat)));

% Regular frequencies.
if any(ixReg)
    year(ixReg) = floor( double(serial(ixReg)) ./ double(freq(ixReg)) );
    per(ixReg) = round(serial(ixReg) - year(ixReg).*freq(ixReg) + 1);
end

% Unspecified frequency.
if any(ixZero)
    year(ixZero) = NaN;
    per(ixZero) = serial(ixZero);
end

% Daily frequency; dat2ypf not applicable.
if any(ixDaily)
    year(ixDaily) = NaN;
    per(ixDaily) = serial(ixDaily);
end

% Weekly frequency.
if any(ixWeekly)
    x = ww2day(serial(ixWeekly));
    [year(ixWeekly), per(ixWeekly)] = day2ypfweekly(x);
end

end
