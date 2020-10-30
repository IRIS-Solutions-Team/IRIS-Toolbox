function this = replaceData(this, pairs)

% >=R2019b
%{
arguments
    this NumericTimeSubscriptable
end

arguments (Repeating)
    pairs
end
%}
% >=R2019b

if isempty(this.Data)
    return
end

for i = 1 : numel(pairs)
    this.Data(this.Data==pairs{i}(1)) = pairs{i}(2);
end

this = trim(this);

end%

