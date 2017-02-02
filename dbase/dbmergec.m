function d = dbmergec(d, lsCol, mergedCol)

if ischar(lsCol)
    if ~isempty(strfind(lsCol, ',..,'))
        lsCol = parse(parser.doubledot.Keyword.COMMA, lsCol);
    end
    lsCol = regexp(lsCol, '\w+', 'match');
end

x = [ ];

for i = 1 : length(lsCol)
    name = lsCol{i};
    x = horzcat(x, d.(name)); %#ok<AGROW>
end

d.(mergedCol) = x;

end
