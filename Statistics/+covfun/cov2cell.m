function cellData = cov2cell(data, rowNames, columnNames)

isNamedMatrix = nargin>1;
if isNamedMatrix && nargin==2
    columnNames = rowNames;
end

numPeriods = size(data, 3);
numPages = size(data, 4);
cellData = cell(numPeriods, numPages);
for v = 1 : numPages
    for t = 1 : numPeriods
        if isNamedMatrix
            cellData{t, v} = namedmat(data(:, :, t, v), rowNames, columnNames);
        else
            cellData{t, v} = data(:, :, t, v);
        end
    end
end

end%

