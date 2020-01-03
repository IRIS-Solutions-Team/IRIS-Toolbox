function outputDate = dd(year, varargin)
% dd  Daily dates returned as DateWrapper object or numeric values
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted
%
%     OutputDate = dd(Year, ~Month, ~Day)
%
%
% __Input Arguments__
%
% * `Year` [ numeric ] - Input year.
%
% * `~Month` [ numeric | char | cellstr ] - Input calendar month in year;
% if omitted `Month=1`; `Month` can be also specified as a three-letter
% English abbreviation: `'Jan'`, `'Feb'`, ... `'Dec'`.
%
% * `~Day` [ numeric ] - Input calendar day in month; if omitted, `Day=1`;
% `'end'` means the end day of the respective month.
%
%
% __Output Arguments__
%
% * `OutputDate` [ DateWrapper ] - DateWrapper object representing a daily
% date.
%
%
% __Description__
%
% This function returns a DateWrapper object representing a daily date.
%
%
% __Example__
%
%     >> d = dd(2010, 12, 3)
%     d = 
%       1x1 Daily Date(s)
%         '2010-Dec-03'
%
%     >> dat2str(d)
%     ans =
%         1x1 cell array
%           {'2010-Dec-03'}
% 

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = numeric.dd(year, varargin{:});
outputDate = DateWrapper(dateCode);

end%
