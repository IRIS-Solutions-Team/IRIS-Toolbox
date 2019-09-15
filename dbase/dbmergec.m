function d = dbmergec(d, listColumns, mergedCol)

if ischar(listColumns)
    listColumns = parser.DoubleDot.parse(listColumns, parser.DoubleDot.COMMA);
    listColumns = regexp(listColumns, '\w+', 'match');
end

x = [ ];

for i = 1 : length(listColumns)
    name = listColumns{i};
    x = horzcat(x, d.(name)); %#ok<AGROW>
end

d.(mergedCol) = x;

end%

