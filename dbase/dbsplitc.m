function d = dbsplitc(d, col, listColumns)

if ischar(listColumns)
    listColumns = parser.DoubleDot.parse(listColumns, parser.DoubleDot.COMMA);
    listColumns = regexp(listColumns, '\w+', 'match');
end

if ischar(col)
    x = d.(col);
else
    x = col;
end
isSeries = isa(x, 'tseries');
ref = repmat({':'}, 1, ndims(x)-2);

for i = 1 : length(listColumns)
    newName = listColumns{i};
    if isSeries
        d.(newName) = x;
        d.(newName).data = d.(newName).data(:, i, ref{:});
        d.(newName).Comment = d.(newName).Comment(:, i, ref{:});
    else
        d.(newName) = x(:, i, ref{:});
    end
end

end%

