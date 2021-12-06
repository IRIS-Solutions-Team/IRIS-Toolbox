function serial = serialFromYmd(freq, year, month, day)

freq = round(double(freq));
switch freq
    case Frequency__.Yearly
        serial = Frequency.serialize(freq, year);
    case Frequency__.HalfYearly
        serial = Frequency.serialize(freq, year, Frequency.month2period(freq, month));
    case Frequency__.Quarterly
        serial = Frequency.serialize(freq, year, Frequency.month2period(freq, month));
    case Frequency__.Monthly
        serial = Frequency.serialize(freq, year, month);
    otherwise
        serial = Frequency.serialize(freq, year, month, day);
end

end%

