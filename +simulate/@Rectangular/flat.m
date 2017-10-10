function flat(this, data, firstColumn, lastColumn, deviation)

nxi = this.NumOfStates;
nf = this.NumOfForward;
ny = this.NumOfObserved;
ne = this.NumOfShocks;
idOfObserved = this.IdOfObserved;
idOfShocks = this.IdOfShocks;
idOfStates = this.IdOfStates;
idOfBackward = idOfStates(nf+1:end);
[T, R, K, Z, H, D] = this.Solution{:};

if ne>0
    expectedShocks = this.Expected( data.YXEPG(idOfShocks, :) );
    unexpectedShocks = this.Unexpected( data.YXEPG(idOfShocks, :) );
    lastExpectedShock = find(any(expectedShocks~=0, 1), 1, 'last');
    if isempty(lastExpectedShock)
        lastExpectedShock = 0;
    end
    currentForward = size(R, 2)/ne - 1;
    requiredForward = lastExpectedShock - firstColumn;
    if requiredForward>currentForward
        R = model.expandFirstOrder(R, [ ], this.Expansion, requiredForward);
        this.Solution{2} = R;
    end
end

linxOfStates = sub2ind(size(data.YXEPG), real(idOfStates), firstColumn+imag(idOfStates));
linxOfBackward = linxOfStates(nf+1:end);
indexOfCurrent = imag(idOfStates)==0;
linxOfCurrent = linxOfStates(indexOfCurrent);
linxStep = size(data.YXEPG, 1);

if any(this.IndexOfLog)
    data.YXEPG(this.IndexOfLog, :) = log(data.YXEPG(this.IndexOfLog, :));
end

for t = firstColumn : lastColumn
    % __Endogenous variables__
    Xi_t = T*data.YXEPG(linxOfBackward-linxStep);
    if ~deviation
        Xi_t = Xi_t + K;
    end
    if ne>0
        if t<=lastExpectedShock
            ahead = lastExpectedShock - t + 1;
            shocks = expectedShocks(:, t:lastExpectedShock);
            shocks(:, 1) = shocks(:, 1) + unexpectedShocks(:, t);
            Xi_t = Xi_t + R(:, 1:ahead*ne)*shocks(:);
        else
            Xi_t = Xi_t + R(:, 1:ne)*unexpectedShocks(:, t);
        end
    end
    data.YXEPG(linxOfCurrent) = Xi_t(indexOfCurrent);

    % __Observables__
    if ny>0
        Y_t = Z*Xi_t(nf+1:end);
        if ne>0
            Y_t = Y_t + H*(expectedShocks(:, t) + unexpectedShocks(:, t));
        end
        if ~deviation
            Y_t = Y_t + D;
        end
        data.YXEPG(idOfObserved, t) = Y_t;
    end

    % Update linear indexes by one column ahead.
    linxOfStates = round(linxOfStates + linxStep);
    linxOfBackward = round(linxOfBackward + linxStep);
    linxOfCurrent = round(linxOfCurrent + linxStep);
end

if any(this.IndexOfLog)
    data.YXEPG(this.IndexOfLog, :) = exp(data.YXEPG(this.IndexOfLog, :));
end

end

