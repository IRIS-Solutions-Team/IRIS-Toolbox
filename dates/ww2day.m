function day = ww2day(dat, wday)
% ww2day  Convert weekly IRIS serial date number to Matlab serial date number.
%
% Syntax
% =======
%
%     Day = ww2day(Dat)
%     Day = ww2day(Dat,WDay)
%
% Input arguments
% ================
%
% * `Dat` [ numeric ] - IRIS serial number for weekly date.
%
% * `WDay` [ `'Mon'` | `'Tue'` | `'Wed'` | `'Thu'` | `'Fri'` | `'Sat'` |
% `'Sun'` ] - The day of the week that will represent the input week,
% `Dat`; if omitted, the week will be represented by its Thursday.
%
% Output arguments
% =================
%
% * `Day` [ numeric ] - Matlab serial date number representing Thursday in
% that week.
%
% Description
% ============
%
% Example
% ========
%
% The first week of the year 2009 starts on Monday, 29 December 2008 (it is
% the first week of 2009 by ISO 8601 definition, because Thursday of that
% week falls in 2009).
%
% The following command returns the Thursday of that week (note that
% `datestr` is a standard Matlab function, not an IRIS function),
%
%     firstWeek09 = ww(2009,1);
%     datestr( ww2day(firstWeek09) )
%     ans =
%     01-Jan-2009
%
% while this command returns the Monday of the same week,
%
%     datestr( ww2day(firstWeek09,'Monday') )
%     ans =
%     29-Dec-2008
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    wday; %#ok<VUNUS>
catch
    wday = iris.get('Wday');
end

days = {'Mon','Tue','Wed','Thu','Fri','Sat','Sun'};

%--------------------------------------------------------------------------

% First week in year 0 starts on Monday, January 3. IRIS serial number for
% this week (0W1) is 0.
start = 3;

p = find(strncmpi(wday, days, 3), 1) - 1;
if isempty(p)
    utils.error('dates:ww2day', ...
        'This is not a valid day of week: ''%s''.',wday);
end

% Matlab serial number for the requested day in the `Dat` week, depending
% on the position `p`.
day = start + floor(dat)*7 + p;

end
