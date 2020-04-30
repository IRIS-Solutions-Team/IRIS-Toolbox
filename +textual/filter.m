function [filtered, excluded] = filter(func, inputList)

inx = arrayfun(func, string(inputList));
filtered = inputList(inx);
excluded = inputList(~inx);

end%
