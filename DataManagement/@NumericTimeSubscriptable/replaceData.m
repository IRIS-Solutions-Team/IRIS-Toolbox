function this = replaceData(this, pairs)

arguments
    this NumericTimeSubscriptable
end

arguments (Repeating)
    pairs
end

if isempty(this.Data)
    return
end

for i = 1 : numel(pairs)
    this.Data(this.Data==pairs{i}(1)) = pairs{i}(2);
end

this = trim(this);

end%

