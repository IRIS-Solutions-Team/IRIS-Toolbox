function code = encodeSpecs(specs)

specsNames = reshape(string(fieldnames(specs)), 1, [ ]);

% Regular specs: specs.X11_Mode
% Force specs: specs.Automdl
inxRegular = contains(specsNames, "_");
regularSpecsNames = specsNames(inxRegular);
forceSpecsNames = specsNames(~inxRegular);

store = struct( );
for n = regularSpecsNames
    prefix = extractBefore(n, "_");
    name = extractAfter(n, "_");
    if isempty(prefix)
        continue
    end
    if ~isfield(store, prefix)
        store = locallyInitializeSpec(store, prefix);
    end
    if strlength(name)==0
        continue
    end
    value = specs.(n);
    if isempty(value)
        continue
    end
    isDate = locallyTellDate(n);
    [value, useBrackets] = locallyTranslateValue(value, isDate);
    code = locallyEncodeAttribute(name, value, useBrackets);
    store.(prefix) = [store.(prefix); code];
end

%
% ## Force Specs ##
%
% If the user specifies `specs.XXX = true`, then the spec XXX will be included
% no matter what (even empty). If `specs.XXX = false`, then the spec will
% neven be include (even when non-empty). If the `specs.XXX` is empty
% (default), then the inclusion is based on the presence of at least one
% non-empty setting.
%

for n = forceSpecsNames
    value = specs.(n);
    if isempty(value)
        continue
    end
    if value
        if ~isfield(store, n)
            store = locallyInitializeSpec(store, n);
        end
    else
        if isfield(store, n)
            store = rmfield(store, n)
        end
    end
end
            
code = string.empty(0, 1);
for n = reshape(string(fieldnames(store)), 1, [ ])
    code = [code; n + "{"; store.(n); "}"; " "];
end
code = join(code, newline);

end%

%
% Local Functions
%

function store = locallyInitializeSpec(store, prefix)
    store.(prefix) = string.empty(0, 1);
end%


function [value, useBrackets] = locallyTranslateValue(value, isDate)
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
        if all(round(value)==value)
            format = "%g";
        else
            format = "%.10f";
        end
        numColumns = size(value, 2);
        if numColumns>1
            format = join(repmat(format, 1, numColumns), " ");
        end
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


function code = locallyEncodeAttribute(name, value, useBrackets)
    code = "    " + name + "=";
    if useBrackets
        code = code + "(";
    end
    if isscalar(value)
        code = code + value;
        if useBrackets
            code = code + ")";
        end
    else
        code = [code; "    " + value];
        if useBrackets
            code = [code; "    )"];
        end
    end
end%


function isDate = locallyTellDate(name)
    isDate = endsWith(name, ["Start", "Span"], "IgnoreCase", true);
end%


