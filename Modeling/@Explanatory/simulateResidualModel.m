function [runningDb, innovations] = simulateResidualModel(this, runningDb, range)

range = double(range);
startDate = range(1);
endDate = range(end);
numPeriods = round(endDate - startDate + 1);
endPresample = dater.plus(startDate, -1);

for this__ = reshape(this, 1, [ ])
    if this__.IsIdentity
        continue
    end

    %
    % Retrieve data from the time series
    %
    residualName = this__.ResidualName;
    if isfield(runningDb, residualName)
        data = getDataFromTo(runningDb.(residualName), -Inf, endPresample);
        data = data(:, :);
        if ~isempty(data)
            data(~isfinite(data)) = 0;
        end
    else
        data = zeros(0, 1);
    end


    %
    % Determine the total number of runs, and expand data if needed
    %
    numPages = size(data, 2);
    nv = countVariants(this__);
    numRuns = max(nv, numPages);
    if numPages==1 && numRuns>1
        data = repmat(data, 1, numRuns);
    end

    residualModel = this__.ResidualModel;
    newData = zeros(numPeriods, numRuns);
    if ~isempty(data) && ~isempty(this__.ResidualModel) && ~this__.ResidualModel.IsIdentity
        for v = 1 : numRuns
            residualModel = update(residualModel, this__.ResidualModelParameters(:, :, v));
            innovations = filter(inv(residualModel), data(:, v));
            innovations = [innovations; zeros(numPeriods, 1)];
            temp = filter(residualModel, innovations); 
            newData(:, v) = temp(end-numPeriods+1:end);
        end
    end
    runningDb.(residualName) = setData( ...
        runningDb.(residualName) ...
        , dater.colon(startDate, endDate) ...
        , newData ...
    );
end

end%

