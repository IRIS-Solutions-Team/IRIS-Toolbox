%{
---
title: today
---

# `dater.today`

{== Create today's dater of a given frequency ==}


## Syntax

    t = dater.today(freq)


%}


%---8<---


function dateCode = today(freq)

% >=R2019b
%{
arguments
    freq (1, 1) Frequency
end
%}
% >=R2019b


here_checkFrequency();
[year, month, day] = datevec(now());
dateCode = dater.fromSerial(freq, dater.serialFromYmd(freq, year, month, day));

return

    function here_checkFrequency()
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

