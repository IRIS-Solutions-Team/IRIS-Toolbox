function this = redate(this, oldDate, newDate)

persistent pp
if isempty(pp)
    pp = extend.InputParser('tseries.redate');
    pp.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    pp.addRequired('OldDate', @validate.date);
    pp.addRequired('NewDate', @validate.date);
end
parse(pp, this, oldDate, newDate);

%--------------------------------------------------------------------------

oldDate = double(oldDate);
newDate = double(newDate);
freqSeries = this.FrequencyAsNumeric;
freqOldDate = dater.getFrequency(oldDate);

if freqOldDate~=freqSeries
    throw( exception.Base('Series:FrequencyMismatch', 'error'), ...
           char(Frequency(freqSeries)), char(Frequency(freqOldDate)) );
end

oldStart = double(this.Start);
shift = round(oldStart - oldDate);
this.Start = dater.plus(newDate, shift);

end%
