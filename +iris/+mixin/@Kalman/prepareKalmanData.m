
function [inputArray, trendLine] = prepareKalmanData(this, inputData, range, whenMissing)

    if isnumeric(inputData)
        inputArray = inputData;
        trendLine = [];
        return
    end

    if isa(inputData, 'Series')
        range = double(range);
        inputArray = getDataFromTo(inputData, range(1), range(end));
        inputArray = permute(inputArray, [2, 1, 3]);
        return
    end

    [measurementNames, exogenousNames, logNames] = getKalmanDataNames(this);
    numY = numel(measurementNames);
    inputDataNames = [measurementNames, exogenousNames];
    numYG = numel(inputDataNames);
    if ~isempty(inputData) && ~isempty(fieldnames(inputData))
        allowedNumeric = @all;
        context = "";
        dbInfo = checkInputDatabank( ...
            this, inputData, range ...
            , [], inputDataNames ...
            , allowedNumeric, logNames ...
            , context ...
        );
        inputArray = requestData( ...
            this, dbInfo, inputData ...
            , inputDataNames, range ...
        );
        inputArray = ensureLog(this, dbInfo, inputArray, inputDataNames);
    else
        numBasePeriods = dater.rangeLength(range);
        inputArray = nan(numYG, numBasePeriods);
    end

    [inputArray, trendLine] = insertTrendLine(this, inputArray, range, inputDataNames);

    inxMissing = any(all(isnan(inputArray), 2), 3);
    if any(inxMissing(1:numY))
        exception.(whenMissing)([
            "Kalman"
            "This measurement variable has no observations available: %s"
        ], measurementNames(inxMissing(1:numY)));
    end
    if any(inxMissing(numY+1:end))
        exception.(whenMissing)([
            "Kalman"
            "This exogenous variable has no observations available: %s"
        ], exogenousNames(inxMissing(numY+1:end)));
    end

end%

