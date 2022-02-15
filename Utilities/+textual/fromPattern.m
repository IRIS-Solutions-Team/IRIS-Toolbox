function output = fromPattern(base, pattern)

arguments
    base (1, :) string
    pattern (1, 2) string
end

output = pattern(1) + base + pattern(2);

end%

