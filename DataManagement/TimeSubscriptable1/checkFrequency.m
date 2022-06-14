function checkFrequency(this, dates, type)

if any(~validateFrequencyOrInf(this, dates))
    freqOfThis = dater.getFrequency(this.Start);
    freqOfDates = dater.getFrequency(dates);
    freqOfDates = unique(freqOfDates, 'stable');
    charFreqOfDates = arrayfun(@Frequency.toChar, freqOfDates, 'UniformOutput', false);
    if nargin<3
        type = 'error';
    end
    throw( exception.Base('TimeSubscriptable:FrequencyMismatch', type), ...
           Frequency.toChar(freqOfThis), charFreqOfDates{:} );
end

end%

