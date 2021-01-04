function this = infoset2line(this, range)

[data, startDate] = getDataFromTo(this, double(range));
sizeData = size(data);
nd = length(sizeData);
if length(sizeData)>3
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

if length(sizeData)>3
    data = reshape(data, [size(data, 1), size(data, 2), sizeData(3:end)]);
end

this = fill(this, data, startDate);

end%

