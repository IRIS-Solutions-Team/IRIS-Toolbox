function dec = day2dec(day)
% day2dec  Convert Matlab serial date numbers to decimal representation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

day = floor(day);
[year, ~, ~] = datevec(day);
yearStart = datenum(year, 1, 1);
nDay = daysinyear(year);
dayCount = day - yearStart;
dec = year + dayCount ./ nDay;

end
