function outputArray = toDoubleArrayNoFrills(inputDatabank, names, dates, column)

numberOfNames = numel(names);
numberOfDates = numel(dates);

if numberOfNames==0
    outputArray = double.empty(numberOfDates, 0);
    return
end

outputArray = nan(numberOfDates, numberOfNames);
for i = 1 : numberOfNames
    try
        ts = inputDatabank.(char(names(i)));
        sizeData = size(ts);
        nCols = prod(sizeData(2:end));
        if nCols==1
            outputArray(:, i) = getDataNoFrills(ts, dates, 1);
        elseif nCols>1
            outputArray(:, i) = getDataNoFrills(ts, dates, column);
        end
    end
end

end
