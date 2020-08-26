function freq = getFrequency(dateCode)

freq = round(100*(double(dateCode) - floor(dateCode)));
inxZero = freq==0;
if any(inxZero)
    inxDaily = freq==0 & floor(dateCode)>=Frequency.MIN_DAILY_SERIAL;
    freq(inxDaily) = 365;
end

end%


