
function [dataColumns, startDates, freq] = splitDataColumns(inputSeries)

    inputData = inputSeries.Data;
    inputStart = inputSeries.StartAsNumeric;
    freq = dater.getFrequency(inputStart);

    inputData = inputData(:, :);
    numColumns = size(inputData, 2);

    dataColumns = cell(1, numColumns);
    startDates = nan(1, numColumns);
    inxFiniteData = isfinite(inputData);
    for i = 1 : numColumns
        first = find(inxFiniteData(:, i), 1, 'first');
        last = find(inxFiniteData(:, i), 1, 'last');
        if ~isempty(first) && ~isempty(last)
            dataColumns{i} = inputData(first:last, i);
            startDates(i) = dater.plus(inputStart, first-1);
        end
    end

end%

