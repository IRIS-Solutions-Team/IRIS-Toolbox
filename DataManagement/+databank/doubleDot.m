function x = doubleDot(inputDatabank, expression)

list = parser.DoubleDot.parse(expression, parser.DoubleDot.COMMA);
list = reshape(split(string(list), ","), 1, [ ]);

x = double.empty(0);
for name = list
    x = [x; inputDatabank.(name)];
end

end%

