function code = compileSpecs(specName, opt)

code = string.empty(0, 1);

specName = lower(specName);
names = lower(keys(opt));
values = struct2cell(opt);

inxKeep = startsWith(names, specName + "_", "IgnoreCase", true);
names(~inxKeep) = [ ];
values(~inxKeep) = [ ];

for i = 1 : numel(names)
    if isequal(values{i}, @default)
        continue
    end
    value__ = series.x13.convertToString(values{i});
    if names(i)=="save" && isempty(value__)
        continue
    end
    code(end+1, 1) = "     " + lower(extractAfter(names(i), "_")) + "=" + value__;
end

if isempty(code) && any(specName==lower(opt.ExcludeEmpty))
    return
end

code = [specName + "{"; code; "}"; " "; " "];

end%

