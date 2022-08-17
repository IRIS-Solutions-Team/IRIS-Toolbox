function outputDb = mtimes(inputDb, list)

list = string(list);
if isa(inputDb, 'Dictionary')
    outputDb = retrieve(inputDb, list);
else
    outputDb = rmfield(inputDb, setdiff(keys(inputDb), list));
end

end%

