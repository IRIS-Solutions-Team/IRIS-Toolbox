function N = persinyear(Year,Freq)
% weeksinyear  Number of periods of given date frequency in year.
%
% Syntax
% =======
%
%     N = persinyear(Year)
%
% Input arguments
% ================
%
% * `Year` [ numeric ] - Year.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of periods of giver date frequency in year
% `Year`.
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

switch Freq
    case {0,1,2,4,6,12}
        N = Freq*ones(size(Year));
    case 52
        N = weeksinyear(Year);
    case 365
        N = daysinyear(Year);
    otherwise
        N = nan(size(Year));
end

end
