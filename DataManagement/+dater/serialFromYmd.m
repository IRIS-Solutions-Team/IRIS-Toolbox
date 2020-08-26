function serial = serialFromYmd(freq, year, month, day)

freq = round(double(freq));
switch freq
    case 1
        serial = Frequency.serialize(freq, year);
    case 2
        serial = Frequency.serialize(freq, year, Frequency.month2period(freq, month));
    case 4
        serial = Frequency.serialize(freq, year, Frequency.month2period(freq, month));
    case 12
        serial = Frequency.serialize(freq, year, month);
    otherwise
        serial = Frequency.serialize(freq, year, month, day);
end

end%

