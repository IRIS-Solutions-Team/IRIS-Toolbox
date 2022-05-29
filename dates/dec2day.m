function Day = dec2day(Dec)
% dec2day  [Not a public function] Convert decimal representation of dates
% to Matlab serial date numbers.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

year = floor(Dec);
nDay = daysinyear(year);
yearStart = datenum(year,1,1);
dayCount = round((Dec - year) .* nDay);
Day = yearStart + dayCount;

end
