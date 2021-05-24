% Type `web Dater/toString.md` for help on this function
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function outputString = toString(inputDate, dateFormat, options)

arguments
    inputDate {mustBeNumeric}
    dateFormat (1, 1) string

    options.Open (1, 1) string = ""
    options.Close (1, 1) string = ""
end
%)
% >=R2019b


% <=R2019a
%{
function outputString = toString(inputDate, dateFormat, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addParameter(pp, 'Open', "");
    addParameter(pp, 'Close', "");
end
parse(pp, varargin{:});
options = pp.Results;
%}
% <=R2019a


inputDate = double(inputDate);
sizeInput = size(inputDate);
[outputString, map] = locallyParseDateFormat(dateFormat, options);
outputString = repmat(outputString, sizeInput);

[year, period, frequency] = dater.getYearPeriodFrequency(inputDate);

for n = map
    token = n(1);
    standin = n(2);
    print = locallyPrintToken(inputDate, token, year, period, frequency);
    for i = 1 : numel(outputString)
        outputString(i) = replace(outputString(i), standin, print(i));
    end
end

end%

%
% Local Functions
%

function [dateFormat, map] = locallyParseDateFormat(dateFormat, options)
    tokensAvailable = [
        "yyyy"; "yy"; "y"
        "mmmm"; "mmm"; "mm"; "m"; "n"; "N"
        "pp"; "p"; "r"; "R"
        "f"; "F"
        "dd"; "d"; "ee"; "e"
    ];
    map = string.empty(2, 0);
    count = 0;
    for token = reshape(tokensAvailable, 1, [])
        extendedToken = options.Open + token + options.Close;
        if contains(dateFormat, extendedToken)
            if count>=32
                exception.error([
                    "Dater:TooManyFormattingTokens"
                    "The number of formatting tokens is limited to 32 in"
                    "one DateFormat string."
                ]);
            end
            standin = char(count);
            dateFormat = replace(dateFormat, extendedToken, standin);
            map(:, end+1) = [token; standin];
            count = count + 1;
        end
    end
end%


function print = locallyPrintToken(date, token, year, period, freq)
    month = [];
    day = [];
    eomd = [];
    if startsWith(token, ["m", "n", "d", "e"], "ignoreCase", true)
        [month, day, eomd] = locallyGetMonthDay(date);
    end

    switch token
        case "yyyy"
            print = compose("%04g", year);
        case "yy"
            print = compose("%g", year);
            n = strlength(print);
            inx = n>2;
            if any(inx(:))
                print(inx) = eraseBetween(print(inx), 1, n(inx)-2);
            end
        case "y"
            print = compose("%g", year);
        case "mmmm"
            print = dater.stringFromMonth(month);
        case "mmm"
            print = extractBefore(dater.stringFromMonth(month), 4);
        case "mm"
            print = compose("%02g", month);
        case "m"
            print = compose("%g", month);
        case "n"
            print = locallyGetRoman(month);
        case "N"
            print = upper(locallyGetRoman(month));
        case "dd"
            print = compose("%02g", day); 
        case "d"
            print = compose("%g", day); 
        case "ee"
            print = compose("%02g", eomd); 
        case "e"
            print = compose("%g", eomd); 
        case "pp"
            print = compose("%02g", period);
        case "p"
            print = compose("%g", period);
        case "r"
            print = compose("%s", locallyGetRoman(period));
        case "R"
            print = compose("%s", upper(locallyGetRoman(period)));
        case {"f", "F"}
            freqLetters = repmat("", 1, 366);
            freqLetters(0+1) = "i";
            freqLetters(1+1) = "y";
            freqLetters(2+1) = "h";
            freqLetters(4+1) = "n";
            freqLetters(12+1) = "m";
            freqLetters(52+1) = "m";
            freqLetters(101+1) = "?";
            freqLetters(365+1) = "d";
            if token=="F"
                freqLetters = upper(freqLetters);
            end
            freq(~isfinite(freq)) = 101;
            print = compose("%s", freqLetters(freq+1));
        otherwise
            print = repmat("", size(date));
    end

    print = locallyPostprocess(print, token, freq);
end%


function [month, day, eomd] = locallyGetMonthDay(date)
    daily = convert(date, Frequency.DAILY);
    [year, month, day] = datevec(daily);
    eomd = eomday(year, month);
end%


function print = locallyPostprocess(print, token, freq)
    if startsWith(token, "p")
        print(freq==Frequency.YEARLY) = "";
    end

    if startsWith(token, "y")
        print(freq==Frequency.INTEGER) = "";
    end
end%


function roman = locallyGetRoman(number)
    roman = [
        "i"; "ii"; "iii"; "iv"; "v"; "vi";
        "vii"; "viii"; "ix"; "x"; "xi"; "xii";
        "?"
    ];
    number(~isfinite(number)) = 13;
    roman = roman(number);
end%

