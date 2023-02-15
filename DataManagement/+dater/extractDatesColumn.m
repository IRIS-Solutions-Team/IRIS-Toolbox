function outputDates = extractDatesColumn(dates, freq, reference)

    inxMiss = cellfun(@(x) any(ismissing(x)) || isempty(x), dates);
    if all(inxMiss)
        outputDates = nan(size(dates));
        return
    end
    pos = find(~inxMiss, 1);

    if isa(dates{pos}, 'datetime')
        if any(inxMiss)
            dates(inxMiss) = {NaT};
        end
        dates = reshape([dates{:}], [], 1);
        try
            outputDates = dater.fromMatlab(freq, dates);
            return
        end
    end

    if ischar(dates{pos})
        dates = reshape(dates, [], 1);
        outputDates = nan(size(dates));
        if isnan(freq)
            return
        end
        if isIsoString(dates{pos})
            try
                outputDates(~inxMiss) = dater.fromIsoString(freq, dates(~inxMiss));
                return
            end
        end
        try
            outputDates(~inxMiss) = dater.fromDefaultString(freq, dates(~inxMiss));
            return
        end
    end

    exception.error(["Dater"; "Invalid date column %s"], reference);

    return

        function out = isIsoString(x)
            if ~ischar(x) && ~isstring(x)
                out = false;
                return
            end
            x = char(x);
            out = strlength(x)==10 && x(5)=='-' &&  x(8)=='-';
        end%
end%


