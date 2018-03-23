function dat = day2ww(day)
% day2ww  Convert Matlab serial date number into weekly IRIS serial date number.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(day) || iscellstr(day)
    day = datenum(day);
end
day = floor(day);

% First week in year 0 starts on Monday, January 3. Matlab serial date
% number for this day is 3.
start = 3;

% IRIS serial number for the first week in year 0 (0W1) is 0.
serial = floor((day - start) / 7);

dat = serial + 0.52;

end
