function code = compileSpecs(specName, outputTables, opt)

code = string.empty(0, 1);

list = reshape(string(fieldnames(opt)), 1, [ ]);
list = list( ...
    startsWith(list, specName + "_", "IgnoreCase", true) ...
    & ~endsWith(list, "_ExcludeEmpty", "IgnoreCase", true) ...
);

for n = list
    if isequal(opt.(n), @default)
        continue
    end
    code(end+1, 1) = ...
        "     " + erase(n, specName + "_") + "=" ...
        + series.x13.convertToString(opt.(n));
end

if isempty(code) && opt.(specName + "_ExcludeEmpty") 
    return
end

code = [ 
    lower(specName) + "{"
    code
    "}"
    " "
    " "
];

end%

