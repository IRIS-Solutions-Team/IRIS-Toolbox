function code = compileSpecs(specName, outputTables, opt)

code = string.empty(0, 1);

specName = lower(specName);
list = lower(keys(opt));
list = list(startsWith(list, specName + "_"));

for n = list
    if isequal(opt.(n), @default)
        continue
    end
    code(end+1, 1) = ...
        "     " + erase(n, specName + "_") + "=" ...
        + series.x13.convertToString(opt.(n));
end

if isempty(code) && any(specName==lower(opt.ExcludeEmpty))
    return
end

code = [specName + "{"; code; "}"; " "; " "];

end%

