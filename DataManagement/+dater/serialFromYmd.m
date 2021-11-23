function serial = serialFromYmd(freq, year, month, day)

freq = round(double(freq));
switch freq
    case Frequency.Yearly
        serial = Frequency.serialize(freq, year);
    case Frequency.HalfYearly
        serial = Frequency.serialize(freq, year, Frequency.month2period(freq, month));
    case Frequency.Quarterly
        serial = Frequency.serialize(freq, year, Frequency.month2period(freq, month));
    case Frequency.Monthly
        serial = Frequency.serialize(freq, year, month);
    otherwise
        serial = Frequency.serialize(freq, year, month, day);
end

end%

