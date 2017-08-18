function [data, from] = getDataFromRange(this, from, to)

sizeData = size(this.Data);
ndimsData = numel(sizeData);

isinfFrom = isinf(from);
isinfTo = isinf(to);

if isinfFrom && isinfTo
    data = this.Data;
    from = this.Start;
    return
end

if isnad(this.Start)
    missingValue = this.MissingValue;
    n = between(from, to);
    data = repmat(missingValue, [n, sizeData(2:end)]);
    return
end

if isinfFrom
    posFrom = 1;
else
    posFrom = between(this.Start, from);
end

if isinfTo
    posTo = sizeData(1);
else
    posTo = between(this.Start, to);
end

pos = (posFrom : posTo).';
n = length(pos);
ix = pos>=1 & pos<=sizeData(1);
if all(ix)
    data = this.Data(pos, :);
    if ndimsData>2
        data = reshape(data, [n, sizeData(2:end)]);
    end
else
    missingValue = this.MissingValue;
    data = repmat(missingValue, [n, sizeData(2:end)]);
    data(ix, :) = this.Data(pos(ix), :);
end

end
