function N = daysinyear(Year)
% daysinyear  Number of days in year.
%
% Syntax
% =======
%
%     N = daysinyear(Year)
%
% Input arguments
% ================
%
% * `Year` [ numeric ] - Year.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of days in `Year`.
%
% Description
% ============
%
% `N` is `365` for non-leap years, and `366` for leap years. Leap years are
% either years divisible by `4` but not `100`, or years divisible by `400`.
%
% Example
% ========
%
%     daysinyear([2000,2200])
%     ans =
%        366   365
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

N = nan(size(Year));

isLeap = (rem(Year,4) == 0 & rem(Year,100) ~= 0) | rem(Year,400) == 0;

N(~isLeap) = 365;
N(isLeap) = 366;

end
