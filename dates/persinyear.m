function numOfPeriods = persinyear(year, freq)
% persinyear  Number of periods of given date frequency in year
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

switch double(freq)
    case {0, 1, 2, 4, 6, 12}
        numOfPeriods = freq*ones(size(year));
    case 52
        numOfPeriods = weeksinyear(year);
    case 365
        numOfPeriods = daysinyear(year);
    otherwise
        numOfPeriods = nan(size(year));
end

end%
