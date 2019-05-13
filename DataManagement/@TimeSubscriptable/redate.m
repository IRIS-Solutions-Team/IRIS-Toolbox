function this = redate(this, oldDate, newDate)
% redate  Change time dimension of time series
%
% __Syntax__
%
%     x = redate(x, oldDate, newDate)
%
%
% __Input Arguments__
%
% * `x` [ tseries ] - Input time series.
%
% * `oldDate` [ DateWrapper ] - Base date that will be converted to a new
% date; `oldDate` does not need to be the stard date of `X` and does not
% even need to be within the current date range of `X`.
%
% * `newDate` [ DateWrapper ] - A new date to which the base date `oldDate`
% will be changed; `newDate` need not be the same frequency as `oldDate`.
%
%
% __Output Arguments__
%
% * `x` [ tseries ] - Output tseries object with identical data as the
% input tseries object, but with its time dimension changed.
%
%
% __Description__
%
%
% __Example__
%
% Create a time series on a date range from `2000Q1` to `2000Q4`. Change
% the time dimension of the time series so that `1999Q4` (which is a date
% outside the original time series range) changes into `2009Q4` (which will
% again be a date outside the new time series range).
%
%     >> x = Series(qq(2000, 1):qq(2000, 4), 1:4)
%     x =
%         Series object: 4-by-1
%         2000Q1:  1
%         2000Q2:  2
%         2000Q3:  3
%         2000Q4:  4
%         ''
%         User Data: empty
%
%     >> redate(x, qq(1999, 4), qq(2009, 4))
%     ans =
%         Series object: 4-by-1
%         2010Q1:  1
%         2010Q2:  2
%         2010Q3:  3
%         2010Q4:  4
%         ''
%         User Data: empty
%


% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('tseries.redate');
    parser.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    parser.addRequired('OldDate', @DateWrapper.validateDateInput);
    parser.addRequired('NewDate', @DateWrapper.validateDateInput);
end
parser.parse(this, oldDate, newDate);

%--------------------------------------------------------------------------

oldDate = double(oldDate);
newDate = double(newDate);
freqOfSeries = this.FrequencyAsNumeric;
freqOfOldDate = DateWrapper.getFrequencyAsNumeric(oldDate);

if freqOfOldDate~=freqOfSeries
    throw( exception.Base('Series:FrequencyMismatch', 'error'), ...
           char(Frequency(freqOfSeries)), char(Frequency(freqOfOldDate)) );
end

oldStart = double(this.Start);
shift = round(oldStart - oldDate);
newStart = DateWrapper.fromDateCode(newDate);
newStart = addTo(newStart, shift);
this.Start = newStart;

end%

