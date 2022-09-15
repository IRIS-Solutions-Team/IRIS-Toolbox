function [vec, inx] = recognizeSdmxFreq(sdmxDates)

sizeDates = size(sdmxDates);

inx.Yearly = false(sizeDates);
inx.HalfYearly = false(sizeDates);
inx.Quarterly = false(sizeDates);
inx.Monthly = false(sizeDates);
inx.Weekly = false(sizeDates);
inx.Daily = false(sizeDates);
inx.Integer = false(sizeDates);
inx.Unknown = false(sizeDates);

len = strlength(sdmxDates);

% Yearly "2020"
inx.Yearly = len==4;

% Half-yearly "2020-B1" or "2020-H1" or "2020-S1"
inx.HalfYearly = len==7 & contains(sdmxDates, ["-B", "-H", "-S"], "ignoreCase", true);

% Quarterly "2020-Q1"
inx.Quarterly = len==7 & contains(sdmxDates, "-Q", "ignoreCase", true);

% Monthly "2020-01"
inx.Monthly = len==7 & contains(sdmxDates, "-") & ~contains(sdmxDates, ["-B", "-H", "-S", "-Q"]);

% Weekly "2020-W01"
inx.Weekly = len==8 & contains(sdmxDates, "-W", "ignoreCase", true);

% Daily "2020-01-01"
inx.Daily = len==10 & contains(sdmxDates, "-");

% Integer "(10)"
inx.Integer = startsWith(sdmxDates, "(") & endsWith(sdmxDates, ")");

% Unrecognized
inx.Unknown = ~inx.Yearly & ~inx.HalfYearly & ~inx.Quarterly & ~inx.Monthly & ~inx.Weekly & ~inx.Daily & ~inx.Integer;

if any(inx.Unknown)
    exception.error([
        "DataForms:UnrecognizableDateString"
        "This is not a valid SDMX date string: %s"
    ], sdmxDates(inx.Unknown));
end

vec = ...
    + frequency.YEARLY * double(inx.Yearly) ...
    + frequency.HALFYEARLY * double(inx.HalfYearly) ...
    + frequency.QUARTERLY * double(inx.Quarterly) ...
    + frequency.MONTHLY * double(inx.Monthly) ...
    + frequency.WEEKLY * double(inx.Weekly) ...
    + frequency.DAILY * double(inx.Daily) ...
    + frequency.INTEGER * double(inx.Integer) ...
;

vec(vec==0) = frequency.NaN;

end%
