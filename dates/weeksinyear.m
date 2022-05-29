function N = weeksinyear(Year)
% weeksinyear  Number of weeks in year.
%
% Syntax
% =======
%
%     N = weeksinyear(Year)
%
% Input arguments
% ================
%
% * `Year` [ numeric ] - Year.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of weeks in `Year`.
%
% Description
% ============
%
% The number of weeks in a year is either `52` or `53`, and complies with
% the definition of the first week in a year in ISO 8601. The first week of
% a year is the one that contains the 4th day of January (in other words,
% has most of its days in that year).
%
% Example
% ========
%
%     weeksinyear(2000:2010)
%     ans =
%         52    52    52    52    53    52    52    52    52    53    52
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Monday in the first week of the year.
first = fwymonday(Year);

% Monday in the first week of the next year;
firstNext = fwymonday(Year+1);

% Number of weeks in between.
N = (firstNext - first) / 7;

end
