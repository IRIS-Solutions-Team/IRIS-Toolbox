function outputNames = filterFields(inputDb, options)

%[
% R2019b
arguments
    inputDb (1, 1) { validate.databank(inputDb) }
    options.Name  (1, 1) function_handle = @all
    options.Value  (1, 1) function_handle = @all
end
% R2019b
%]

allKeys = keys(inputDb);

isNameFilter = ~isequal(options.Name, @all);
isValueFilter = ~isequal(options.Value, @all);

if ~isNameFilter && ~isValueFilter
    outputNames = allKeys;
    return
end

inxPassed = logical.empty(1, 0);
for k = allKeys
   passed = true;
   if isNameFilter
       passed = passed && isequal(options.Name(k), true);
   end
   if passed && isValueFilter
       if isa(inputDb, "Dictionary")
           value = retrieve(inputDb, k);
       else
           value = inputDb.(k);
       end
       passed = passed && isequal(options.Value(value), true);
   end
   inxPassed(end+1) = passed;
end

outputNames = allKeys(inxPassed);

end%

