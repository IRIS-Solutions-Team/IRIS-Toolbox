function [data, start, first, last] = trimRows(data, start, missingValue, missingTest)

first = [ ];
last = [ ];

if isempty(data)
    return
end

dataFirst = data(1, :);
dataLast = data(end, :);
if ~all(missingTest(dataFirst)) && ~all(missingTest(dataLast))
    return
end

sizeOfData = size(data);
indexOfMissing = all(missingTest(data(:, :)), 2);
if all(indexOfMissing)
    first = 1;
    last = 0;
    data = repmat(missingValue, [0, sizeOfData(2:end)]);
    start = DateWrapper.NaD( );
    return
end

first = find(~indexOfMissing, 1);
last = find(~indexOfMissing, 1, 'last');
n = last - first + 1;
data = reshape(data(first:last, :), [n, sizeOfData(2:end)]);
start = addTo(start, first-1);

end
