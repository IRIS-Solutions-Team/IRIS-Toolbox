function outputData = moving(inputData, freq, window, func, missingValue, missingTest, periodByPeriod)

arguments
    inputData double
    freq (1, 1) double

    window = @auto
    func = @mean
    missingValue = NaN
    missingTest = @isnan
    periodByPeriod = false
end

sizeData = size(inputData);
window = locallyResolveWindow(window, freq);
if isempty(window)
    inputData = reshape(inputData([], :), [0, sizeData(2:end)]);
    return
end

numRows = sizeData(1);
numColumns = prod(sizeData(2:end));

outputData = inputData;
for column = 1 : numColumns
    if ~isreal(window)
        inxMissing = missingTest(inputData(:, column));
        windowLength = imag(window);
        windowOffset = real(window);
        if windowLength~=0 || ~all(inxMissing)
            for row = 1 : numRows
                selectData = locallySelectNonmissingData(inputData(:, column), inxMissing, row, windowLength, windowOffset);
                if ~isempty(selectData)
                    outputData(row, column) = feval(func, selectData);
                else
                    outputData(row, column) = missingValue;
                end
            end
        else
            outputData(:, column) = repmat(missingValue, numRows, 1);
        end
    else
        shiftedData = series.shift(inputData(:, column), window);
        if ~periodByPeriod
            outputData(:, column) = transpose(feval(func, transpose(shiftedData), 1));
        else
            % Use a for loop to make sure only the respective moving window of
            % observations shaped as a column vector enters the function
            for row = 1 : numRows
                outputData(row, column) = feval(func, reshape(shiftedData(row, :), [], 1));
            end
        end
    end
end

end%

%
% Local functions
%

function selectData = locallySelectNonmissingData(data, inxMissing, row, windowLength, windowOffset)
    %(
    direction = sign(windowLength);
    windowLength = abs(windowLength);
    if direction>0
        selectData = data(row+windowOffset:end);
        inxMissing = inxMissing(row+windowOffset:end);
    else
        selectData = data(1:row+windowOffset);
        inxMissing = inxMissing(1:row+windowOffset);
    end

    selectData(inxMissing) = [];
    if numel(selectData)<windowLength
        selectData = [];
        return
    end

    if direction>0
        selectData = selectData(1:windowLength);
    else
        selectData = selectData(end-windowLength+1:end);
    end
    %)
end%

%
% Local Validators
%

function window = locallyResolveWindow(window, freq)
    %(
    AUTO_WINDOW_FREQUENCIES = Frequency([1, 2, 4, 12]);
    if isnumeric(window) 
        window = reshape(window, 1, []);
        return
    end
    if ismember(freq, AUTO_WINDOW_FREQUENCIES)
        window = (-freq+1) : 0;
        return
    end
    exception.error([
        "Series:InvalidMovingWindow"
        "Option Window=@auto is not allowed for time series of %s frequency. "
    ], string(Frequency(freq)));
    %)
end%


