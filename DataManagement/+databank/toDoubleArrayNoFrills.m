function outputArray = toDoubleArrayNoFrills(inputDatabank, names, dates, column)

numberOfNames = numel(names);
numberOfDates = numel(dates);

if numberOfNames==0
    outputArray = double.empty(numberOfDates, 0);
    return
end

outputArray = nan(numberOfDates, numberOfNames);
for i = 1 : numberOfNames
    if isa(names, 'string')
        ithName = char(names(i));
    else
        ithName = names{i};
    end
    if ~isfield(inputDatabank, ithName) || ~isa(inputDatabank.(ithName), 'series.Abstract')
        continue
    end
    field = inputDatabank.(ithName);
    sizeData = size(field);
    numOfColumns = prod(sizeData(2:end));
    if numOfColumns==1
        outputArray(:, i) = getDataNoFrills(field, dates, 1);
    elseif numOfColumns>1
        try
            outputArray(:, i) = getDataNoFrills(field, dates, column);
        end
    end
end

end
