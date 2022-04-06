classdef frequency

    properties (Constant)
        YEARLY = 1
        HALFYEARLY = 2
        QUARTERLY = 4
        MONTHLY = 12
        WEEKLY = 52
        DAILY = 365
        INTEGER = 0
        NaN = NaN
        NaF = NaN

        FREQ_LETTERS = [
            "Y", "A", "H", "B", "S", "Q", "M", "W", "D", "I"
        ]

        ALL_FREQUENCIES = [
            frequency.YEARLY, frequency.HALFYEARLY, frequency.QUARTERLY ...
            , frequency.MONTHLY, frequency.WEEKLY, frequency.DAILY, frequency.INTEGER ...
        ]
    end


    methods (Static)
        function letter = toLetter(freq)
            freq = double(freq);
            letter = repmat("", size(freq));
            letter(freq==frequency.YEARLY) = "Y";
            letter(freq==frequency.HALFYEARLY) = "H";
            letter(freq==frequency.QUARTERLY) = "Q";
            letter(freq==frequency.MONTHLY) = "M";
            letter(freq==frequency.WEEKLY) = "W";
            letter(freq==frequency.DAILY) = "D";
            letter(freq==frequency.INTEGER) = "I";
        end%


        function letter = toImfLetter(freq)
            freq = double(freq);
            letter = repmat("", size(freq));
            letter(freq==frequency.YEARLY) = "A";
            letter(freq==frequency.HALFYEARLY) = "B";
            letter(freq==frequency.QUARTERLY) = "Q";
            letter(freq==frequency.MONTHLY) = "M";
            letter(freq==frequency.WEEKLY) = "W";
            letter(freq==frequency.DAILY) = "D";
            letter(freq==frequency.INTEGER) = "I";
        end%


        function freq = fromString(freqString)
            switch upper(char(string(freqString)))
                case {'INTEGER', 'II', 'I'}
                    this = frequency.INTEGER;
                case {'DAILY', 'DAY', 'DD', 'D', 'B', 'BUSINESS'}
                    this = frequency.DAILY;
                case {'WEEKLY', 'WEEK', 'WW', 'W'}
                    this = frequency.WEEKLY;
                case {'MONTHLY', 'MONTH', 'MM', 'M'}
                    this = frequency.MONTHLY;
                case {'QUARTERLY', 'QUARTER', 'QQ', 'Q'}
                    this = frequency.QUARTERLY;
                case {'HALFYEARLY', 'HALFYEAR', 'SEMIANNUAL', 'SEMIANNUALLY', 'HH', 'H', 'B', 'S'}
                    this = frequency.HALFYEARLY;
                case {'YEARLY', 'YEAR', 'ANNUAL', 'ANNUALLY', 'YY', 'Y', 'A'}
                    this = frequency.YEARLY;
                otherwise
                    this = frequency.NaN;
            end
        end%
    end

end

