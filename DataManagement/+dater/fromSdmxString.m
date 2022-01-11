function dates = dateFromEcbString(freq, sdmxDate)

sizeInput = size(sdmxDate);
sdmxDate = reshape(string(sdmxDate), [], 1);

[inxYearly, inxHalfYearly, inxQuarterly, inxMonthly, inxWeekly, inxDaily] ...
    = hereRecognizeFrequency(freq, sdmxDate);

dates = nan(size(sdmxDate));

if any(inxYearly)
    dates(inxYearly) = yy(double(sdmxDate(inxYearly)));
end

if any(inxHalfYearly)
    temp = locallySplitToNumbers(sdmxDate(inxHalfYearly), "-B");
    dates(inxHalfYearly) = dater.hh(temp(:, 1), temp(:, 2));
end

if any(inxQuarterly)
    temp = locallySplitToNumbers(sdmxDate(inxQuarterly), "-Q");
    dates(inxQuarterly) = dater.qq(temp(:, 1), temp(:, 2));
end

if any(inxMonthly)
    temp = locallySplitToNumbers(sdmxDate(inxMonthly), "-");
    dates(inxMonthly) = dater.mm(temp(:, 1), temp(:, 2));
end

if any(inxWeekly)
    temp = locallySplitToNumbers(sdmxDate(inxWeekly), "-W");
    dates(inxWeekly) = dater.ww(temp(:, 1), temp(:, 2));
end

if any(inxDaily)
    dates(inxDaily) = dater.fromIsoString(Frequency.DAILY, sdmxDate(inxDaily));
end

dates = reshape(dates, sizeInput);

return

    function [inxYearly, inxHalfYearly, inxQuarterly, inxMonthly, inxWeekly, inxDaily] ...
            = hereRecognizeFrequency(freq, sdmxDate)
        %(
        inxYearly = false(sizeInput);
        inxHalfYearly = false(sizeInput);
        inxQuarterly = false(sizeInput);
        inxMonthly = false(sizeInput);
        inxWeekly = false(sizeInput);
        inxDaily = false(sizeInput);
        if isequal(freq, Frequency__.Yearly)
            inxYearly(:) = true;
            return
        elseif isequal(freq, Frequency__.HalfYearly)
            inxHalfYearly(:) = true;
            return
        elseif isequal(freq, Frequency__.Quarterly)
            inxQuarterly(:) = true;
            return
        elseif isequal(freq, Frequency__.Monthly)
            inxMonthly(:) = true;
            return
        elseif isequal(freq, Frequency__.Weekly)
            inxWeekly(:) = true;
            return
        elseif isequal(freq, Frequency__.Daily)
            inxDaily(:) = true;
            return
        end

        len = strlength(sdmxDate);
        % Yearly "2020"
        inxYearly = len==4;

        % Half-yearly "2020-B1"
        inxHalfYearly = len==7 & contains(sdmxDate, "-B", "ignoreCase", true);

        % Quarterly "2020-Q1"
        inxQuarterly = len==7 & contains(sdmxDate, "-Q", "ignoreCase", true);

        % Monthly "2020-01"
        inxMonthly = len==7 & contains(sdmxDate, "-") & ~contains(sdmxDate, ["-B", "-Q"]);

        % Weekly "2020-W01"
        inxWeekly = len==8 & contains(sdmxDate, "-W", "ignoreCase", true);

        % Daily "2020-01-01"
        inxDaily = len==10 & contains(sdmxDate, "-");

        % Unrecognized
        inxUnknown = ~inxYearly & ~inxHalfYearly & ~inxQuarterly & ~inxMonthly & ~inxWeekly & ~inxDaily;

        if any(inxUnknown)
            exception.error([
                "DataForms:UnrecognizableDateString"
                "This is not a valid ECB date string: %s"
            ], sdmxDate(inxUnknown));
        end
        %)
    end%
end%

%
% Local functions
%

function outputNumbers = locallySplitToNumbers(inputStrings, divider)
    %(
    outputNumbers = double(split(reshape(string(inputStrings), [], 1), divider));
    if isscalar(inputStrings)
        outputNumbers = transpose(outputNumbers);
    end
    %)
end%


