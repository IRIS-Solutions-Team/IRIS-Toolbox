function [year, month, day] = ymdFromSerial(freq, serial, position)

freq = round(double(freq));
serial = double(serial);

if nargin>=3
    position = lower(extractBefore(string(position), 2));
    if ~any(position==["s", "m", "e"])
        position = "s";
    end
else
    position = "s";
end

switch freq
    case 1
        year = Frequency.deserialize(freq, serial);
        switch position
            case "s" % Start of period
                month = ones(size(year));
                day = ones(size(year));
            case "m" % Middle of period
                month = repmat(6, size(year));
                day = repmat(30, size(year));
            case "e" % End of period
                month = repmat(12, size(year));
                day = repmat(31, size(year));
        end
    case 2
        [year, halfyear] = Frequency.deserialize(freq, serial);
        month = 6*(halfyear-1);
        switch position
            case "s" % Start of period
                month = month + 1;
                day = ones(size(year));
            case "m" % Middle of period
                month = month + 4;
                day = ones(size(year));
            case "e" % End of period
                month = month + 6;
                day = eomday(year, month);
        end 
    case 4
        [year, quarter] = Frequency.deserialize(freq, serial);
        month = 3*(quarter-1);
        switch position
            case "s" % Start of period
                month = month + 1;
                day = ones(size(year));
            case "m" % Middle of period
                month = month + 2;
                day = repmat(15, size(year));
            case "e" % End of period
                month = month + 3;
                day = eomday(year, month);
        end
    case 12
        [year, month] = Frequency.deserialize(freq, serial);
        switch position
            case "s" % Start of period
                day = ones(size(year));
            case "m" % Middle of period
                day = repmat(15, size(year));
            case "e" % End of period
                day = eomday(year, month);
        end
    case 52
        [year, month, day] = Frequency.deserialize(freq, serial);
        switch position
            case "s" % Start of period
                day = day - 3; % Return Monday
            case "m" % Middle of period
                day = day + 0; % Return Thursday
            case "e" % End of period
                day = day + 3; % Return Sunday
        end
    case 365
        [year, month, day] = Frequency.deserialize(freq, serial);
    otherwise
        year = nan(size(serial));
        month = nan(size(serial));
        day = nan(size(serial));
end

year = round(year);
month = round(month);
day = round(day);

end%

