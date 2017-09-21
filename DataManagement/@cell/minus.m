function x = minus(x, y)

if ischar(x)
    x = {x};
end

if ischar(y)
    y = {y};
end
if isstruct(y)
    y = fieldnames(y);
end
[x, ix] = setdiff(x, y);
[~, ixBack] = sort(ix);
x = x(ixBack);
end