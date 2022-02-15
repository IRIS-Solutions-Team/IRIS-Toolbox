function lines = wrapList(list, limit, delimiter)

lines = string.empty(0, 1);
list = string(list);
delimiter = string(delimiter);

currentLine = "";
while ~isempty(list)
    if strlength(currentLine)==0
        currentLine = list(1);
    else
        currentLine = currentLine + delimiter + list(1);
    end
    list(1) = [ ];
    if strlength(currentLine)>=limit
        lines = [lines; currentLine];
        currentLine = "";
    end
end

if strlength(currentLine)>=0
    lines = [lines; currentLine];
end

end%

