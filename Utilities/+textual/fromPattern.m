function output = fromPattern(base, pattern)

% >=R2019b
%(
arguments
    base (1, :) string
    pattern (1, 2) string
end
%)
% >=R2019b


output = string(pattern(1)) + string(base) + string(pattern(2));

end%

