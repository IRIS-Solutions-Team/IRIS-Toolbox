
function dates = fromSdmxString(sdmxDate)

sdmxDate = string(sdmxDate);
sizeInput = size(sdmxDate);
sdmxDate = reshape(sdmxDate, [], 1);
[~, inx] = dater.recognizeSdmxFreq(sdmxDate);

dates = nan(size(sdmxDate));

if any(inx.Yearly)
    dates(inx.Yearly) = yy(double(sdmxDate(inx.Yearly)));
end

if any(inx.HalfYearly)
    temp = local_splitToNumbers(sdmxDate(inx.HalfYearly), ["-B", "-H", "-S"]);
    dates(inx.HalfYearly) = dater.hh(temp(:, 1), temp(:, 2));
end

if any(inx.Quarterly)
    temp = local_splitToNumbers(sdmxDate(inx.Quarterly), "-Q");
    dates(inx.Quarterly) = dater.qq(temp(:, 1), temp(:, 2));
end

if any(inx.Monthly)
    temp = local_splitToNumbers(sdmxDate(inx.Monthly), "-");
    dates(inx.Monthly) = dater.mm(temp(:, 1), temp(:, 2));
end

if any(inx.Weekly)
    temp = local_splitToNumbers(sdmxDate(inx.Weekly), "-W");
    dates(inx.Weekly) = dater.ww(temp(:, 1), temp(:, 2));
end

if any(inx.Daily)
    dates(inx.Daily) = dater.fromIsoString(Frequency.DAILY, sdmxDate(inx.Daily));
end

if any(inx.Integer)
    temp = double(extractBetween(sdmxDate, "(", ")"));
    dates(inx.Integer) = dater.ii(temp);
end

dates = reshape(dates, sizeInput);

end%

%
% Local functions
%

function outputNumbers = local_splitToNumbers(inputStrings, divider)
    %(
    outputNumbers = double(split(reshape(string(inputStrings), [], 1), divider));
    if isscalar(inputStrings)
        outputNumbers = transpose(outputNumbers);
    end
    %)
end%

