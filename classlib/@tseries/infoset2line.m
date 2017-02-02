function this = infoset2line(this, range)

if ischar(range)
    range = textinp2dat(range);
end
range = range(1) : range(end);

data = rangedata(this, range);
sz = size(data);
nd = length(sz);
if length(sz)>3
    data = data(:,:,:);
end

data = permute(data, [2, 1, 3:nd]);

nRow = size(data, 1);
nCol = size(data, 2);
data(end+(1:nCol-1), :, :) = NaN;
for i = 2 : nCol
    x = data(1:nRow, i, :);
    data(:, i, :) = NaN;
    data((i-1)+(1:nRow), i, :) = x;
end

if length(sz)>3
    data = reshape(data, [size(data, 1), size(data, 2), sz(3:end)]);
end

this = replace(this, data, range(1));

end
