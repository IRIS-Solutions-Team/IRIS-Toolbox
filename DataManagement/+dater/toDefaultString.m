function defaultString = toDefaultString(dates, letterFromFreq)

    if nargin<2
        letterFromFreq = @frequency.toLetter;
    end

    dates = double(dates);
    defaultString = repmat("", size(dates));

    [year, per, freq] = dat2ypf(dates);
    freqLetters = letterFromFreq(freq);

    inx = isnan(dates);
    if nnz(inx)>0
        defaultString(inx) = "NaN";
    end

    inx = isinf(dates) & dates<0;
    if nnz(inx)>0
        defaultString(inx) = "-Inf";
    end

    inx = isinf(dates) & dates>0;
    if nnz(inx)>0
        defaultString(inx) = "Inf";
    end

    inx = freq==0;
    if nnz(inx)>0
        defaultString(inx) = "(" + string(dates(inx)) + ")";
    end

    inx = freq==365;
    if nnz(inx)>0
        defaultString(inx) = datestr(dates(inx), "yyyy-mmm-dd");
    end

    inx = freq==1;
    if nnz(inx)>0
        yearString = string(reshape(year(inx), [], 1));
        freqLetterString = string(reshape(freqLetters(inx), [], 1));
        defaultString(inx) = yearString + freqLetterString;
    end

    inx = freq==12 | freq==52;
    if nnz(inx)>0
        perString = string(reshape(per(inx), [], 1));
        inxAddZero = strlength(perString)==1;
        perString(inxAddZero) = "0" + perString(inxAddZero);
        yearString = string(reshape(year(inx), [], 1));
        freqLetterString = string(reshape(freqLetters(inx), [], 1));
        defaultString(inx) = yearString + freqLetterString + perString;
    end

    inx = freq==2 | freq==4;
    if nnz(inx)>0
        perString = string(reshape(per(inx), [], 1));
        yearString = string(reshape(year(inx), [], 1));
        freqLetterString = string(reshape(freqLetters(inx), [], 1));
        defaultString(inx) = yearString + freqLetterString + perString;
    end

end%

