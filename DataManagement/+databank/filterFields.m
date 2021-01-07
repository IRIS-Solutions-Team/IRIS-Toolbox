function outputNames = filterFields(inputDb, options)

% >=R2019b
%(
arguments
    inputDb (1, 1) { validate.databank(inputDb) }
    options.Name (1, 1) function_handle = @all
    options.Class (1, :) {locallyValidateClass} = @all
    options.Value (1, 1) function_handle = @all
end
%)
% >=R2019b

isNameFilter = ~isequal(options.Name, @all);
isClassFilter = ~isequal(options.Class, @all);
isValueFilter = ~isequal(options.Value, @all);

allKeys = reshape(string(fieldnames(inputDb)), 1, [ ]);
if ~isNameFilter && ~isClassFilter && ~isValueFilter
    outputNames = allKeys;
    return
end

shortlist = allKeys;

if isNameFilter
    shortlistUpdate = string.empty(1, 0);
    for n = shortlist
        if isequal(options.Name(n), true)
            shortlistUpdate(end+1) = n;
        end
    end
    shortlist = shortlistUpdate;
end


if isClassFilter
    options.Class = reshape(string(options.Class), 1, []);
    shortlistUpdate = string.empty(1, 0);
    for n = shortlist
        if isa(inputDb, "Dictionary")
            value = retrieve(inputDb, n);
        else
            value = inputDb.(n);
        end
        for c = options.Class
            if isa(value, c)
                shortlistUpdate(end+1) = n;
                break
            end
        end
    end
    shortlist = shortlistUpdate;
end

if isValueFilter
    shortlistUpdate = string.empty(1, 0);
    for n = shortlist
        if isa(inputDb, "Dictionary")
            value = retrieve(inputDb, n);
        else
            value = inputDb.(n);
        end
        if isequal(options.Value(value), true)
            shortlistUpdate(end+1) = n;
        end
    end
    shortlist = shortlistUpdate;
end

outputNames = shortlist;

end%

%
% Local Validators
%

function locallyValidateClass(x)
    %( 
    if isequal(x, @all) || isstring(x)
        return
    end
    error("Input value must be a string or array of strings.");
    %)
end%

