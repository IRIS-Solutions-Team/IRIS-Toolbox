function outputDb = load(fileName, items)

arguments
    fileName (1, 1) string
    items (1, :) string = "--all"
end

if isequal(items, "--all")
    items = cell.empty(1, 0);
else
    items = cellstr(items);
end

outputDb = load(fileName, items{:});

end%
