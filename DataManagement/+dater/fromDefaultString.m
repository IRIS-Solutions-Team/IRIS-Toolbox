function t = fromDefaultString(freq, s)

    freqLetter = frequency.toLetter(freq);

    if freq==Frequency.DAILY
        t = datenum(s, "yyyy-mmm-dd");
        return
    end

    switch freq
        case Frequency.INTEGER
            convertFunc = @(x) sscanf(x, "%g");
        case Frequency.WEEKLY
            convertFunc = @here_convertWeekly;
        case Frequency.MONTHLY
            convertFunc = @here_convertMonthly;
        case Frequency.QUARTERLY
            convertFunc = @here_convertQuarterly;
        case Frequency.HALFYEARLY
            convertFunc = @here_convertHalfYearly;
        case Frequency.YEARLY
            convertFunc = @here_convertYearly;
    end

    t = arrayfun(convertFunc, string(s));

    return

    function t = here_convertWeekly(s)
        t = NaN;
        out = sscanf(s, "%g"+freqLetter+"%g");
        if numel(out)==2
            t = dater.ww(out(1), out(2));
        end
    end%

    function t = here_convertMonthly(s)
        t = NaN;
        out = sscanf(s, "%g"+freqLetter+"%g");
        if numel(out)==2
            t = dater.mm(out(1), out(2));
        end
    end%

    function t = here_convertQuarterly(s)
        t = NaN;
        out = sscanf(s, "%g"+freqLetter+"%g");
        if numel(out)==2
            t = dater.qq(out(1), out(2));
        end
    end%

    function t = here_convertHalfYearly(s)
        t = NaN;
        out = sscanf(s, "%g"+freqLetter+"%g");
        if numel(out)==2
            t = dater.hh(out(1), out(2));
        end
    end%

    function t = here_convertYearly(s)
        t = NaN;
        out = sscanf(s, "%g"+freqLetter);
        if numel(out)==1
            t = dater.yy(out(1));
        end
    end%
end%

