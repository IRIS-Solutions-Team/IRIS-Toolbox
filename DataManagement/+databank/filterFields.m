function outputNames = filterFields(inputDb, options)

% >=R2019b
%(
arguments
    inputDb (1, 1) { validate.databank(inputDb) }
    options.Name  (1, 1) function_handle = @all
    options.Value  (1, 1) function_handle = @all
end
%)
% >=R2019b

isNameFilter = ~isequal(options.Name, @all);
isValueFilter = ~isequal(options.Value, @all);

allKeys = reshape(string(fieldnames(inputDb)), 1, [ ]);
if ~isNameFilter && ~isValueFilter
    outputNames = allKeys;
    return
end

if isNameFilter
    inxName = logical.empty(1, 0);
    for n = allKeys
        inxName(end+1) = options.Name(n);
    end
else
    inxName = true(size(allKeys));
end

if isValueFilter
    inxValue = logical.empty(1, 0);
    for n = allKeys
       if isa(inputDb, "Dictionary")
           value = retrieve(inputDb, n);
       else
           value = inputDb.(n);
       end
       inxValue(end+1) = isequal(options.Value(value), true);
    end
else
    inxValue = true(size(allKeys));
end

outputNames = allKeys(inxName & inxValue);

end%

