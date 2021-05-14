function dateCode = today(freq)

% >=R2019b
%(
arguments
    freq (1, 1) Frequency
end
%)
% >=R2019b


hereCheckFrequency();
[year, month, day] = datevec(now());
dateCode = dater.fromSerial(freq, dater.serialFromYmd(freq, year, month, day));

return

    function hereCheckFrequency()
        %(
        if freq==0
            exception.error([
                "Dater:TodayInteger"
                "Cannot create today's date for this date frequency: %s"
            ], string(freq));
        end
        %)
    end%
end%

