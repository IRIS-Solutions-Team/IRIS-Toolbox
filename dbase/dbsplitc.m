function d = dbsplitc(d, col, lsNewCol)

if ischar(lsNewCol)
    if ~isempty(strfind(lsNewCol, ',..,'))
        lsNewCol = parse(parser.doubledot.Keyword.COMMA, lsNewCol);
    end
    lsNewCol = regexp(lsNewCol, '\w+', 'match');
end

if ischar(col)
    x = d.(col);
else
    x = col;
end
isSeries = isa(x, 'tseries');
ref = repmat({':'}, 1, ndims(x)-2);

for i = 1 : length(lsNewCol)
    newName = lsNewCol{i};
    if isSeries
        d.(newName) = x;
        d.(newName).data = d.(newName).data(:, i, ref{:});
        d.(newName).Comment = d.(newName).Comment(:, i, ref{:});
    else
        d.(newName) = x(:, i, ref{:});
    end
end

end
