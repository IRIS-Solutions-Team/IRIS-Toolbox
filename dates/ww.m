function outputDate = ww(year, varargin)
% ww  IRIS serial date number for weekly date
%
% Syntax
% =======
%
%     outputDate = ww(year, week)
%     outputDate = ww(year, month, day)
%
%
% Input arguments
% ================
%
% * `year` [ numeric ] - Calendar year or vector of years.
%
% * `week` [ numeric ] - Calendar week of the year or vector of weeks.
%
% * `month` [ numeric ] - Calendar month or vector of months.
%
% * `day` [ numeric ] - Calendar day of the month or vector of days.
%
%
% Output arguments
% =================
%
% * `outputDate` [ DateWrapper ] - IRIS serial date numbers.
%
%
% Description
% ============
%
% The IRIS weekly dates comply with the ISO 8601 definition:
%
% * every week starts on Monday and ends on Sunday;
%
% * the month or year to which the week belongs is determined by its
% Thurdsay.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = numeric.ww(year, varargin{:});
outputDate = DateWrapper(dateCode);

end%

