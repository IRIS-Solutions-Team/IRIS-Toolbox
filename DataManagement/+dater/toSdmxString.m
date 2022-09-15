function sdmxString = toSdmxString(dates)

dates = double(dates);
sdmxString = repmat("", size(dates));

[year, per, freq] = dater.getYearPeriodFrequency(dates);

inx = isnan(dates);
if nnz(inx)>0
    sdmxString(inx) = "NaD";
end

inx = isinf(dates) & dates<0;
if nnz(inx)>0
    sdmxString(inx) = "-Inf";
end

inx = isinf(dates) & dates>0;
if nnz(inx)>0
    sdmxString(inx) = "Inf";
end

inx = freq==frequency.INTEGER;
if nnz(inx)>0
    sdmxString(inx) = compose("(%g)", dates(inx));
end

inx = freq==frequency.DAILY;
if any(inx)
    sdmxString(inx) = datestr(dates(inx), "yyyy-mm-dd");
end

inx = freq==frequency.YEARLY;
if any(inx)
    sdmxString(inx) = compose("%g", reshape(year(inx), [ ], 1));
end

inx = freq==frequency.HALFYEARLY;
if any(inx)
    sdmxString(inx) = compose( ...
        "%g-S%g" ...
        , [reshape(year(inx), [ ], 1), reshape(per(inx), [ ], 1)] ...
    );
end

inx = freq==frequency.QUARTERLY;;
if any(inx)
    sdmxString(inx) = compose( ...
        "%g-Q%g" ...
        , [reshape(year(inx), [ ], 1), reshape(per(inx), [ ], 1)] ...
    );
end

inx = freq==frequency.MONTHLY;
if any(inx)
    sdmxString(inx) = compose( ...
        "%g-%02g" ...
        , [reshape(year(inx), [ ], 1), reshape(per(inx), [ ], 1)] ...
    );
end

inx = freq==frequency.WEEKLY;
if any(inx)
    sdmxString(inx) = compose( ...
        "%g-W%02g" ...
        , [reshape(year(inx), [ ], 1), reshape(per(inx), [ ], 1)] ...
    );
end

end%

