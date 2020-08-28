function [value, useBrackets] = convertToString(value, isDate)

useBrackets = false;
useBrackets = numel(value)>1;

if isDate
    [year, period, freq] = dater.getYearPeriodFrequency(value);
    value = string(double(year));
    if freq>1
         value = value + "." + string(double(period));
    end
    value = erase(value, ["NaN.NaN", "NaN"]);;
    if numel(value)>1
        value = join(value, ",");
    end
elseif islogical(value)
    temp = repmat("", size(value));
    temp(value) = "yes";
    temp(~value) = "no";
    value = temp;
elseif isnumeric(value)
    value = value(:, :);
    [numRows, numColumns] = size(value);
    if numRows==1
        inxFixed = imag(value)~=0;
        value(inxFixed) = imag(value(inxFixed));
        value(~inxFixed) = real(value(~inxFixed));
    end
    if all(round(value)==value)
        format = "%g";
    else
        format = "%.10f";
    end
    if numColumns>1
        format = repmat(format, 1, numColumns);
    end
    if numRows==1 && any(inxFixed)
        format(inxFixed) = format(inxFixed) + "F";
    end
    format = join(format, " ");
    value = compose(format, value);
elseif isstring(value) || ischar(value) || iscellstr(value)
    value = string(value);
    if numel(value)>1
        value = join(value, " ");
    end
else
    value = string(value);
end

end%

