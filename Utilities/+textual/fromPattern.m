function output = fromPattern(base, pattern)

% >=R2019b
%{
arguments
    base (1, :) string
    pattern (1, 2) string
end
%}
% >=R2019b

output = string(base);
if any(strlength(pattern)>0)
    output = string(pattern(1)) + output + string(pattern(2));
end

end%

