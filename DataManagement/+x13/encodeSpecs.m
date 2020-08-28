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
    [value, useBrackets] = x13.convertToString(value, isDate);
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


