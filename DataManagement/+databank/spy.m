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

numOfSeries = numel(listOfSeries);
inxToKeep = true(1, numOfSeries);
for i = 1 : numel(listOfSeries)
    name = listOfSeries{i};
    if ~isfield(inputDatabank, name) ...
        || ~isa(inputDatabank.(name), 'TimeSubscriptable')
        inxToKeep(i) = false;
    end
end
listOfSeries = listOfSeries(inxToKeep);

numOfSeries = numel(listOfSeries);
lenOfNames = cellfun(@length, listOfSeries, 'UniformOutput', false);
maxLengthOfName = max([lenOfNames{:}]);
numOfPeriods = rnglen(startDate, endDate);
textual.looseLine( );
for i = 1 : numOfSeries
    name = listOfSeries{i};
    fprintf('%*s ', maxLengthOfName, name);
    data = getDataFromTo(inputDatabank.(name), startDate, endDate);
    data = data(:, :);
    inxOfNaNs = all(isnan(data), 2);
    if all(inxOfNaNs)
        fprintf('\n');
        continue
    end
    inxOfZeros = all(data==0, 2);
    spyString = repmat('.', 1, numOfPeriods);
    spyString(~inxOfNaNs) = 'X';
    spyString(inxOfZeros) = 'O';
    posOfLastObs = find(~inxOfNaNs, 1, 'Last');
    spyString(posOfLastObs+1:end) = '.';
    fprintf('%s\n', spyString);
end

textual.looseLine( );

end


