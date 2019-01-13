function outputArray = toDoubleArrayNoFrills(inputDatabank, names, dates, column)

if ~iscellstr(names)
    names = cellstr(names);
end

dates = double(dates);
numOfNames = numel(names);
numOfDates = numel(dates);

if numOfNames==0
    outputArray = double.empty(numOfDates, 0);
    return
end

outputArray = nan(numOfDates, numOfNames);
for i = 1 : numOfNames
    ithName = names{i};
    if ~isfield(inputDatabank, ithName) || ~isa(inputDatabank.(ithName), 'TimeSubscriptable')
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
