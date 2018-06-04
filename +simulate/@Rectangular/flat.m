function flat(this, data)

nf = this.NumOfForward;
ny = this.NumOfObserved;
ne = this.NumOfShocks;

idOfObserved = this.IdOfObserved;
idOfShocks = this.IdOfShocks;
indexOfCurrent = this.IndexOfCurrent;

sizeOfData = size(data.YXEPG);
firstColumn = this.FirstColumn;
lastColumn = this.LastColumn;

linxOfBackward = this.LinxOfBackward;
linxOfCurrent = this.LinxOfCurrent;
stepForLinx = this.NumOfQuantities;

deviation = this.Deviation;
simulateObserved = this.SimulateObserved;

[T, R, K, Z, H, D] = this.FirstOrderSolution{:};

if ne>0
    retrieveExpected = this.RetrieveExpected( data.YXEPG(idOfShocks, :) );
    retrieveUnexpected = this.RetrieveUnexpected( data.YXEPG(idOfShocks, :) );
    lastExpectedShock = find(any(retrieveExpected~=0, 1), 1, 'last');
    if isempty(lastExpectedShock)
        lastExpectedShock = 0;
    end
    requiredForward = lastExpectedShock - firstColumn;
end

if any(this.IndexOfLog)
    data.YXEPG(this.IndexOfLog, :) = log( data.YXEPG(this.IndexOfLog, :) );
end

for t = firstColumn : lastColumn
    % __Endogenous variables__
    Xi_t = T*data.YXEPG(linxOfBackward-stepForLinx);
    if ~deviation
        Xi_t = Xi_t + K;
    end
    if ne>0
        if t<=lastExpectedShock
            ahead = lastExpectedShock - t + 1;
            shocks = retrieveExpected(:, t:lastExpectedShock);
            shocks(:, 1) = shocks(:, 1) + retrieveUnexpected(:, t);
            Xi_t = Xi_t + R(:, 1:ahead*ne)*shocks(:);
        else
            Xi_t = Xi_t + R(:, 1:ne)*retrieveUnexpected(:, t);
        end
    end
    data.YXEPG(linxOfCurrent) = Xi_t(indexOfCurrent);

    % __Observables__
    if simulateObserved && ny>0
        Y_t = Z*Xi_t(nf+1:end);
        if ne>0
            Y_t = Y_t + H*(retrieveExpected(:, t) + retrieveUnexpected(:, t));
        end
        if ~deviation
            Y_t = Y_t + D;
        end
        data.YXEPG(idOfObserved, t) = Y_t;
    end

    % Update linear indexes by one column ahead.
    linxOfBackward = round(linxOfBackward + stepForLinx);
    linxOfCurrent = round(linxOfCurrent + stepForLinx);
end

if any(this.IndexOfLog)
    data.YXEPG(this.IndexOfLog, :) = exp( data.YXEPG(this.IndexOfLog, :) );
end

end

