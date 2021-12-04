function output = splitFunction(input)

input = string(func2str(input));

preamble = extractBefore(input, ")") + ")";

body = extractAfter(input, ")");
if startsWith(body, "[") && endsWith(body, "]")
    body = extractBetween(body, 2, strlength(body)-1);
end

body = textual.stringify(split(body, ";"));
output = cell(size(body));
for i = 1 : numel(body)
    output{i} = str2func(preamble + body(i));
end

end%

