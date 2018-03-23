function this = trim(this)

if isempty(this.Data)
    return
end

missingValue = this.MissingValue;
missingTest = this.MissingTest;
dataFirst = this.Data(1, :);
dataLast = this.Data(end, :);
if ~all(missingTest(dataFirst)) && ~all(missingTest(dataLast))
    return
end

sz = size(this.Data);
ixMissing = all(missingTest(this.Data(:, :)), 2);
if all(ixMissing)
    this.Start = Date.NaD;
    this.Data = repmat(missingValue, [0, sz(2:end)]);
    return
end

first = find(~ixMissing, 1);
last = find(~ixMissing, 1, 'last');
n = last - first + 1;
this.Start = addTo(this.Start, first-1);
this.Data = reshape(this.Data(first:last, :), [n, sz(2:end)]);

end
