classdef frequency

    properties (Constant)
        YEARLY = 1
        Yearly = 1

        HALFYEARLY = 2
        HalfYearly = 2

        QUARTERLY = 4
        Quarterly = 4

        MONTHLY = 12
        Monthly = 12

        WEEKLY = 52
        Weekly = 52

        DAILY = 365
        Daily = 365

        INTEGER = 0
        Integer = 0

        NaN = NaN
        NaF = NaN

        MIN_DAILY_SERIAL = 365244

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
            freqLetters = iris.get("FreqLetters");
            freq = double(freq);
            letter = repmat("", size(freq));
            letter(freq==frequency.YEARLY) = string(freqLetters.yy);
            letter(freq==frequency.HALFYEARLY) = string(freqLetters.hh);
            letter(freq==frequency.QUARTERLY) = string(freqLetters.qq);
            letter(freq==frequency.MONTHLY) = string(freqLetters.mm);
            letter(freq==frequency.WEEKLY) = string(freqLetters.ww);
            letter(freq==frequency.DAILY) = string(freqLetters.dd);
            letter(freq==frequency.INTEGER) = string(freqLetters.ii);
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


        function this = fromString(freqString)
            freqLetters = iris.get("FreqLetters");
            freqString = erase(string(freqString), "_");
            switch upper(char(freqString))
                case {upper(freqLetters.ii), 'INTEGER', 'II', 'I'}
                    this = frequency.INTEGER;
                case {upper(freqLetters.dd), 'DAILY', 'DAY', 'DD', 'D', 'B', 'BUSINESS'}
                    this = frequency.DAILY;
                case {upper(freqLetters.ww), 'WEEKLY', 'WEEK', 'WW', 'W'}
                    this = frequency.WEEKLY;
                case {upper(freqLetters.mm), 'MONTHLY', 'MONTH', 'MM', 'M'}
                    this = frequency.MONTHLY;
                case {upper(freqLetters.qq), 'QUARTERLY', 'QUARTER', 'QQ', 'Q'}
                    this = frequency.QUARTERLY;
                case {upper(freqLetters.hh), 'HALFYEARLY', 'HALFYEAR', 'SEMIANNUAL', 'SEMIANNUALLY', 'HH', 'H', 'B', 'S'}
                    this = frequency.HALFYEARLY;
                case {upper(freqLetters.yy), 'YEARLY', 'YEAR', 'ANNUAL', 'ANNUALLY', 'YY', 'Y', 'A'}
                    this = frequency.YEARLY;
                otherwise
                    this = frequency.NaN;
            end
        end%


        function out = getPrimaryFreqLetters()
            freqLetters = iris.get("FreqLetters");
            out = join([
                freqLetters.ii
                freqLetters.dd
                freqLetters.ww
                freqLetters.mm
                freqLetters.qq
                freqLetters.hh
                freqLetters.yy
            ], "");
        end%
    end

end

