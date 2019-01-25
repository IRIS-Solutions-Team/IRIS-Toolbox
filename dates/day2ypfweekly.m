function [year, per, freq] = day2ypfweekly(day)
% day2ypfweekly  Convert Matlab serial date number to YPF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

per = nan(size(day));
freq = 52*ones(size(day));

% Calendar year.
[year, ~] = datevec(day);

% An ISO 8601 week is Monday to Sunday (European style). Create Matlab
% serial numbers for Monday in the first week of the year, and for Sunday
% in the last week of the year.
first = fwymonday(year);
last = lwysunday(year);

ixBefore = day<first;
if any(ixBefore)
    % This day is in the last week of the previous year.
    year(ixBefore) = year(ixBefore) - 1;
    % Get the number of weeks in this Year-1.
    per(ixBefore) = weeksinyear(year(ixBefore));
end

ixAfter = day>last;
if any(ixAfter)
    % This day is in the first week of the next year.
    year(ixAfter) = year(ixAfter) + 1;
    per(ixAfter) = 1;
end

ixWithin = ~ixBefore & ~ixAfter;
if any(ixWithin)
    per(ixWithin) = floor((day(ixWithin) - first(ixWithin))/7) + 1;
end

end
