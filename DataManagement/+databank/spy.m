
function spy(inputDb, names, startDate, endDate)

    try, endDate, catch, endDate = []; end

    startDate = double(startDate);
    if isempty(endDate)
        endDate = startDate(end);
        startDate = startDate(1);
    end
    endDate = double(endDate);
    freq = dater.getFrequency(startDate);

    if isequal(names, @all) || isequal(names, Inf)
        names = fieldnames(inputDb);
    end

    if ~iscellstr(names)
        names = cellstr(names);
    end

    if isempty(names)
        return
    end

    numSeries = numel(names);
    inxToKeep = true(1, numSeries);
    for i = 1 : numel(names)
        name__ = names{i};
        if ~isfield(inputDb, name__) ...
            || ~isa(inputDb.(name__), 'Series') ...
            || getFrequency(inputDb.(name__))~=freq
            inxToKeep(i) = false;
        end
    end
    names = names(inxToKeep);

    numSeries = numel(names);
    lenNames = cellfun(@length, names, 'UniformOutput', false);
    maxLengthName = max([lenNames{:}]);
    numPeriods = round(endDate - startDate + 1);

    NAME_PATTERN = '%*s  ';

    [years, periods] = dater.getYearPeriodFrequency(startDate:endDate);
    periodString = [fprintf(NAME_PATTERN, maxLengthName, ''), ];

    textual.looseLine();

    fprintf(NAME_PATTERN, maxLengthName, '');
    fprintf('%-2g ', periods);
    fprintf('\n');

    for i = 1 : numSeries
        name__ = names{i};
        fprintf(NAME_PATTERN, maxLengthName, name__);
        series__ = inputDb.(name__);
        data = getDataFromTo(series__, startDate, endDate);
        data = data(:, :);
        inxNaN = all(isnan(data), 2);
        if all(inxNaN)
            fprintf('\n');
            continue
        end
        inxZeros = all(data==0, 2);
        spyString = repmat('.', 1, numPeriods);
        spyString(~inxNaN) = 'X';
        spyString(inxZeros) = 'O';
        posLastObs = find(~inxNaN, 1, 'Last');
        spyString(posLastObs+1:end) = '.';
        temp = spyString;
        spyString = repmat(' ', 1, 3*numPeriods);
        spyString(:, 1:3:end) = temp;
        fprintf('%s\n', spyString);
    end

    textual.looseLine();

end%

