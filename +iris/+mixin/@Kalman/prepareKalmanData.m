
function [inputArray, trendLine] = prepareKalmanData(this, inputDb, range, whenMissing)

    [measurementNames, exogenousNames, logNames] = getKalmanDataNames(this);
    numY = numel(measurementNames);
    inputDataNames = [measurementNames, exogenousNames];
    numYG = numel(inputDataNames);
    if ~isempty(inputDb) && ~isempty(fieldnames(inputDb))
        allowedNumeric = @all;
        context = "";
        dbInfo = checkInputDatabank( ...
            this, inputDb, range ...
            , [], inputDataNames ...
            , allowedNumeric, logNames ...
            , context ...
        );
        inputArray = requestData( ...
            this, dbInfo, inputDb ...
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
        raise(exception.Base(["Kalman", "This measurement variable has no observations available: %s"], whenMissing), measurementNames(inxMissing(1:numY)));
    end
    if any(inxMissing(numY+1:end))
        raise(exception.Base(["Kalman", "This exogenous variable has no observations available: %s"], whenMissing), exogenousNames(inxMissing(numY+1:end)));
    end

end%

