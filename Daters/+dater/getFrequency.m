function freq = getFrequency(dateCode)

    dateCode = double(dateCode);
    freq = round(100*(dateCode - floor(dateCode)));
    inxZero = freq==0;
    if any(inxZero)
        inxDaily = inxZero & dateCode>=frequency.MIN_DAILY_SERIAL;
        if any(inxDaily)
            freq(inxDaily) = frequency.Daily;
        end
    end

end%

