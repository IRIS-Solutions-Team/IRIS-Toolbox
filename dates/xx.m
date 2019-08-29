function dateCode = xx(year, varargin)
% xx  Daily dates returned as DateWrapper object or numeric values
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     dateCode = xx(year, ~day)
%
%
% ## Input Arguments ##
%
% * `year` [ numeric ] - Calendar year.
%
% * `~day` [ numeric ] - Day as counted within the calendar year; `day=1`
% means January 1, `day=365` means December 31 for non-leap years, and so
% on; if omitted, `day=1`.
%
%
% ## Output Arguments ##
%
% * `dateCode` [ DateWrapper ] - DateWrapper object representing a daily
% date.
%
%
% ## Description ##
%
% This function returns a DateWrapper object representing a daily date. The
% input arguments are the calendar year and the day count from the
% beginning of the year.
%
%
% ## Example ##
%
%     >> d = xx(2012, 360:366)'
%     d = 
%       7x1 DAILY Date(s)
%         '2012-Dec-25'
%         '2012-Dec-26'
%         '2012-Dec-27'
%         '2012-Dec-28'
%         '2012-Dec-29'
%         '2012-Dec-30'
%         '2012-Dec-31'
%     >> dat2str(d, 'DateFormat=', 'YYYYFP')
%     ans =
%       7x1 cell array
%         {'2012X360'}
%         {'2012X361'}
%         {'2012X362'}
%         {'2012X363'}
%         {'2012X364'}
%         {'2012X365'}
%         {'2012X366'} 
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = numeric.xx(year, varargin{:});
dateCode = DateWrapper(dateCode);

end%

