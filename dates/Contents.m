% dates  Dates and Date Ranges.
%
% Creating IRIS serial date numbers
% ==================================
%
% * [`hh`](dates/hh) - IRIS serial date number for half-yearly date.
% * [`hhtoday`](dates/hhtoday) - IRIS serial date number for current half-year.
% * [`mm`](dates/mm) - IRIS serial date number for monthly date.
% * [`mmtoday`](dates/mmtoday) - IRIS serial date number for current month.
% * [`qq`](dates/qq) - IRIS serial date number for quarterly date.
% * [`qqtoday`](dates/qqtoday) - IRIS serial date number for current quarter.
% * [`ww`](dates/ww) - IRIS serial date number for weekly date.
% * [`wwtoday`](dates/wwtoday) - IRIS serial date number for current week.
% * [`yy`](dates/yy) - IRIS serial date number for yearly date.
% * [`yytoday`](dates/yytoday) - IRIS serial date number for current year.
%
%
% Computing special dates (daily dates only)
% ===========================================
%
% * [`datbom`](dates/datbom) - Beginning of month for the specified daily date.
% * [`datboq`](dates/datboq) - Beginning of quarter for the specified daily date.
% * [`datboy`](dates/datboy) - Beginning of year for the specified daily date.
% * [`dateom`](dates/dateom) - End of month for the specified daily date.
% * [`dateoq`](dates/dateoq) - End of quarter for the specified daily date.
% * [`dateoy`](dates/dateoy) - End of year for the specified daily date.
%
%
% Creating date ranges
% =====================
%
% * [`datrange`](dates/datrange) - Numerically safe way to create a date range.
% * [`dat2ttrend`](dates/dat2ttrend) - Construct linear time trend from date range.
%
%
% Converting dates
% =================
%
% * [`clp2dat`](dates/clp2dat) - Convert text in system clipboard to dates.
% * [`dat2char`](dates/dat2char) - Convert dates to character array.
% * [`dat2charlist`](dates/dat2charlist) - Convert dates to a comma-separated list.
% * [`dat2clp`](dates/dat2clp) - Convert dates to text and paste to system clipboard.
% * [`dat2dec`](dates/dat2dec) - Convert dates to decimal grid.
% * [`dat2str`](dates/dat2str) - Convert IRIS dates to cell array of strings.
% * [`dat2ypf`](dates/dat2ypf) - Convert IRIS serial date number to year, period and frequency.
% * [`dec2dat`](dates/dec2dat) - Convert decimal representation of date to IRIS serial date number.
% * [`str2dat`](dates/str2dat) - Convert strings to IRIS serial date numbers.
%
%
% Date comparison
% ================
%
% * [`datcmp`](dates/datcmp) - Compare two IRIS serial date numbers.
% * [`datdiff`](dates/datdiff) - Number of periods between two dates with check for date frequency.
% * [`rngcmp`](dates/rngcmp) - Compare two IRIS date ranges.
%
%
% Daily and weekly dates
% =======================
%
% * [`daysinyear`](dates/daysinyear) - Number of days in year.
% * [`dd`](dates/dd) - Matlab serial date numbers that can be used to construct daily tseries objects.
% * [`ddtoday`](dates/ddtoday) - Matlab serial date number for today's date.
% * [`ww2day`](dates/ww2day) - Convert weekly IRIS serial date number to Matlab serial date number.
% * [`weeksinyear`](dates/weeksinyear) - Number of weeks in year.
%
%
% Getting on-line help on date functions
% =======================================
%
%     help dates
%     help dates/function_name
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
