function f = fwymonday(year)
% fwy  Matlab serial date number for Monday in the first week of the year.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

% By ISO 8601:
% * Weeks start with Mondays.
% * First week of the year is the week that contains January 4.
jan4 = datenum(year, 1, 4);

% Day of the week: Monday=1, ..., Sunday=7. This is different from Matlab
% where Sunday=1.
jan4dow = weekdayiso(jan4);

% Serial number for Monday in the first week.
f = jan4 - jan4dow + 1; 

end
