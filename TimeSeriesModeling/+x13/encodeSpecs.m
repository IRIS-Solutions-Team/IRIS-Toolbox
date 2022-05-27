function code = encodeSpecs(specs, regularSpecsOrder)

specsNames = reshape(string(fieldnames(specs)), 1, [ ]);

%
% Regular spec example: specs.X11_Mode
% Force spec example: specs.Automdl
%
inxRegular = contains(specsNames, "_");
regularSpecsNames = specsNames(inxRegular);
forceSpecsNames = specsNames(~inxRegular);

%
% Make sure the regular specs follow the prescribed order
%
local_checkInternalMissing(regularSpecsNames, regularSpecsOrder);
regularSpecsNames = intersect(regularSpecsOrder, regularSpecsNames, 'stable');

store = struct( );
for n = regularSpecsNames
    prefix = extractBefore(n, "_");
    name = extractAfter(n, "_");
    if isempty(prefix)
        continue
    end
    if ~isfield(store, prefix)
        store = local_initializeSpec(store, prefix);
    end
    if strlength(name)==0
        continue
    end
    value = specs.(n);
    if isempty(value)
        continue
    end
    isDate = local_tellDate(n);
    [value, useBrackets] = x13.convertToString(value, isDate);
    code = local_encodeAttribute(name, value, useBrackets);
    store.(prefix) = [store.(prefix); code];
end

%
% ## Force Specs ##
%
% If the user specifies `specs.XXX = true`, then the spec XXX will be included
% no matter what (even empty). If `specs.XXX = false`, then the spec will
% never be included (even when non-empty). If the `specs.XXX` is empty
% (default), then the inclusion is based on the presence of at least one
% non-empty setting.
%

invalid = string.empty(1, 0);
for n = forceSpecsNames
    value = specs.(n);
    if isempty(value)
        continue
    elseif isequal(value, true)
        if ~isfield(store, n)
            store = local_initializeSpec(store, n);
        end
    elseif isequal(value, false)
        if isfield(store, n)
            store = rmfield(store, n)
        end
    else
        invalid(end+1) = n;
    end
end

if ~isempty(invalid)
    exception.error([
        "X13"
        "Invalid value of this X13 top-level specs: %s "
    ], invalid);
end


%
% The Series specs must come first; otherwise, the order of the specs in
% the specs file does not matter.
%
orderedSpecs = textual.fields(store);
orderedSpecs(orderedSpecs=="Series") = [];
orderedSpecs = ["Series", sort(orderedSpecs)];


code = string.empty(0, 1);
for n = orderedSpecs
    code = [code; n + "{"; store.(n); "}"; " "];
end
code = join(code, newline);

end%

%
% Local Functions
%

function store = local_initializeSpec(store, prefix)
    store.(prefix) = string.empty(0, 1);
end%


function code = local_encodeAttribute(name, value, useBrackets)
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


function isDate = local_tellDate(name)
    isDate = endsWith(name, ["Start", "Span"], "IgnoreCase", true);
end%


function local_checkInternalMissing(regularSpecsNames, regularSpecsOrder)
    %
    % Catch possible internal inconsistency between the input argument
    % validator and the local_getRegularSpecsOrder function
    %
    %(
    missing = setdiff(regularSpecsNames, regularSpecsOrder);
    if ~isempty(missing)
        exception.error([
            "X13"
            "Internal error; this X13 specs is not included in the order array: %s "
        ], missing);
    end
    %)
end%

