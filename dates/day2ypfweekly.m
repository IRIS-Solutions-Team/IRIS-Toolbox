function [year, per, freq] = day2ypfweekly(day)
% day2ypfweekly  Convert Matlab serial date number to YPF
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

% Calendar year
[year, ~] = datevec(day);

if nargout>=2
    per = nan(size(day));
    freq = 52*ones(size(day));
end

% An ISO 8601 week is Monday to Sunday (European style). Create Matlab
% serial numbers for Monday in the first week of the year, and for Sunday
% in the last week of the year.
first = fwymonday(year);
last = lwysunday(year);

ixBefore = day<first;
if any(ixBefore)
    % This day is in the last week of the previous year.
    year(ixBefore) = year(ixBefore) - 1;
    if nargout>=2
        % Get the number of weeks in this Year-1.
        per(ixBefore) = weeksinyear(year(ixBefore));
    end
end

ixAfter = day>last;
if any(ixAfter)
    % This day is in the first week of the next year.
    year(ixAfter) = year(ixAfter) + 1;
    if nargout>=2
        per(ixAfter) = 1;
    end
end

if nargout>=2
    ixWithin = ~ixBefore & ~ixAfter;
    if any(ixWithin)
        per(ixWithin) = floor((day(ixWithin) - first(ixWithin))/7) + 1;
    end
end

end%

