function serial = serialFromYmd(freq, year, month, day)

freq = round(double(freq));
switch freq
    case frequency.YEARLY
        serial = Frequency.serialize(freq, year);
    case frequency.HALFYEARLY
        serial = Frequency.serialize(freq, year, Frequency.month2period(freq, month));
    case frequency.QUARTERLY
        serial = Frequency.serialize(freq, year, Frequency.month2period(freq, month));
    case frequency.MONTHLY
        serial = Frequency.serialize(freq, year, month);
    case {frequency.WEEKLY, frequency.DAILY}
        serial = Frequency.serialize(freq, year, month, day);
    otherwise
        serial = nan(size(year+month+day));
end

end%

