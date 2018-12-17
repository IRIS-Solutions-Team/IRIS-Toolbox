function outputArray = toDoubleArrayNoFrills(inputDatabank, names, dates, column)

numOfNames = numel(names);
numOfDates = numel(dates);

if numOfNames==0
    outputArray = double.empty(numOfDates, 0);
    return
end

outputArray = nan(numOfDates, numOfNames);
for i = 1 : numOfNames
    if isa(names, 'string')
        ithName = char(names(i));
    else
        ithName = names{i};
    end
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
