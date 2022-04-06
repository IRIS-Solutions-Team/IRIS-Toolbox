function freq = getFrequency(dateCode)

MIN_DAILY_SERIAL = 365244;

dateCode = double(dateCode);
freq = round(100*(dateCode - floor(dateCode)));
inxZero = freq==0;
if any(inxZero)
    inxDaily = inxZero & dateCode>=MIN_DAILY_SERIAL;
    if any(inxDaily)
        freq(inxDaily) = 365;
    end
end

end%

