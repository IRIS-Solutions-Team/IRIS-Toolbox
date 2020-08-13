function items = splitout(inputString, delimiter, opening, closing)

if nargin<2
    delimiter = ",";
end

if nargin<3
    opening = ["(", "[", "{"];
end

if nargin<4
    closing = [")", "]", "}"];
end

inputString = char(inputString);
code = zeros(size(inputString));
for i = reshape(string(opening), 1, [ ])
    code(inputString==char(i)) = 1;
end
for i = reshape(string(closing), 1, [ ])
    code(inputString==char(i)) = -1;
end
code = cumsum(code);
temp = inputString;
temp(code>0) = ' ';
pos = double.empty(1, 0);
for i = reshape(string(delimiter), 1, [ ])
    pos = [pos, find(temp==char(i))];
end
pos = [0, sort(pos), strlength(inputString)+1];

items = string.empty(1, 0);
for i = 1 : numel(pos)-1
    items(end+1) = strip(string(inputString(pos(i)+1:pos(i+1)-1)));
end

end%

