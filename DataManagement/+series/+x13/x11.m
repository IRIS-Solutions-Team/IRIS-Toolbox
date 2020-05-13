function [spec, opt] = x11(outputTables, opt)

spec = string.empty(0, 1);

spec(end+1) = "x11{";

list = reshape(fieldnames(opt), 1, [ ]);
list = replace(list(startsWith(list, "X11")), "X11", "");
for name = list 
    if isequal(opt.(name), @default)
        continue
    end
    spec(end+1) = spec(end+1)
end

end%

