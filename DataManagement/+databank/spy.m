function spy(inputDatabank, listOfSeries, startDate, endDate)

if isequal(listOfSeries, @all)
    listOfSeries = fieldnames(inputDatabank);
end

if ~iscellstr(listOfSeries)
    listOfSeries = cellstr(listOfSeries);
end

if isempty(listOfSeries)
    return
end

numberOfSeries = numel(listOfSeries);
indexToKeep = true(1, numberOfSeries);
for i = 1 : numel(listOfSeries)
    name = listOfSeries{i};
    if ~isfield(inputDatabank, name) ...
        || ~isa(inputDatabank.(name), 'TimeSubscriptable')
        indexToKeep(i) = false;
    end
end
listOfSeries = listOfSeries(indexToKeep);

numberOfSeries = numel(listOfSeries);
lengthOfNames = cellfun(@length, listOfSeries, 'UniformOutput', false);
maxLengthOfName = max([lengthOfNames{:}]);
numberOfPeriods = rnglen(startDate, endDate);
textual.looseLine( );
for i = 1 : numberOfSeries
    name = listOfSeries{i};
    fprintf('%*s ', maxLengthOfName, name);
    data = getDataFromTo(inputDatabank.(name), startDate, endDate);
    data = data(:, :);
    indexOfNaNs = all(isnan(data), 2);
    if all(indexOfNaNs)
        fprintf('\n');
        continue
    end
    indexOfZeros = all(data==0, 2);
    spyString = repmat('.', 1, numberOfPeriods);
    spyString(~indexOfNaNs) = 'X';
    spyString(indexOfZeros) = 'O';
    positionOfLastObs = find(~indexOfNaNs, 1, 'Last');
    spyString(positionOfLastObs+1:end) = '.';
    fprintf('%s\n', spyString);
end

textual.looseLine( );

end

