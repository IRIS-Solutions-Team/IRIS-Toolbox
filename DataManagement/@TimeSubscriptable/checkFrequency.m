function checkFrequency(this, dates, type)

if any(~validateFrequencyOrInf(this, dates))
    freqOfThis = DateWrapper.getFrequencyAsNumeric(this.Start);
    freqOfDates = DateWrapper.getFrequencyAsNumeric(dates);
    freqOfDates = unique(freqOfDates, 'stable');
    charFreqOfDates = arrayfun(@Frequency.toChar, freqOfDates, 'UniformOutput', false);
    if nargin<3
        type = 'error';
    end
    throw( exception.Base('TimeSubscriptable:FrequencyMismatch', type), ...
           Frequency.toChar(freqOfThis), charFreqOfDates{:} );
end

end%

