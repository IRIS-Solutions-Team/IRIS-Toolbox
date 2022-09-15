function outputDates = fromString(inputStrings, format, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "EnforceFrequency", []);
    addParameter(ip, "ConversionMonth", iris.Configuration.ConversionMonth);
    addParameter(ip, "ConversionDay", iris.Configuration.ConversionDay);
    addParameter(ip, "Months", @auto);
end
parse(ip, varargin{:});
opt = ip.Results;

    if isequal(opt.Months, @auto)
        opt.Months = iris.get("Months");
    end
    opt.Months = string(opt.Months);

    format = local_translateFormat(format);

    parsed = regexp(inputStrings, format, "once", "names", "forceCellOutput");
    if ~iscell(parsed)
        parsed = {parsed};
    end

    outputDates = cellfun( ...
        @(x) local_createDate(x, opt), parsed ...
        , "uniformOutput", true ...
    );

end%


function format = local_translateFormat(format)
    format = replace(format, "{YYYY}", "(?<Year>\d{4})");
    format = replace(format, "{H}", "(?<HalfYear>\d{1})");
    format = replace(format, "{HH}", "(?<HalfYear>\d{2})");
    format = replace(format, "{WW}", "(?<Week>\d{2})");
    format = replace(format, "{W?}", "(?<Week>\d{1,2})");
    format = replace(format, "{Q}", "(?<Quarter>\d{1})");
    format = replace(format, "{QQ}", "(?<Quarter>\d{2})");
    format = replace(format, "{MMM}", "(?<MonthText>[A-Za-z]{3,})");
    format = replace(format, "{MM}", "(?<Month>\d{2})");
    format = replace(format, "{M}", "(?<Month>\d{1})");
    format = replace(format, "{M?}", "(?<Month>\d{1,2})");
    format = replace(format, "{DD}", "(?<Day>\d{2})");
    format = replace(format, "{D?}", "(?<Day>\d{1,2})");
end%


function date = local_createDate(s, opt)
    if isempty(s)
        date = NaN;
        return
    end
    for n = textual.fields(s)
        if endsWith(n, "Text")
            continue
        end
        try
            s.(n) = eval(s.(n));
        catch
            s.(n) = NaN;
        end
    end
    if isfield(s, 'MonthText')
        s.Month = local_resolveMonthText(s.MonthText, opt.Months);
    end
    if ~isfield(s, 'Year') || isequaln(s.Year, NaN)
        date = NaN;
        return
    end
    if isfield(s, 'Month') && isfield(s, 'Day')
        date = dater.dd(s.Year, s.Month, s.Day);
    elseif isfield(s, 'Week')
        date = dater.ww(s.Year, s.Week);
    elseif isfield(s, 'Month')
        date = dater.mm(s.Year, s.Month);
    elseif isfield(s, 'Quarter')
        date = dater.qq(s.Year, s.Quarter);
    elseif isfield(s, 'HalfYear')
        date = dater.hh(s.Year, s.HalfYear);
    else
        date = dater.yy(s.Year);
    end
    if ~isempty(opt.EnforceFrequency)
        date = convert( ...
            date, opt.EnforceFrequency ...
            , "conversionMonth", opt.ConversionMonth ...
            , "conversionDay", opt.ConversionDay ...
        );
    end
end%


function month = local_resolveMonthText(monthText, monthNames);
    inx = startsWith(monthNames, string(monthText), "ignoreCase", true);
    if any(inx)
        month = find(inx, 1);
    else
        month = NaN;
    end
end%

