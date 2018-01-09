function flat(this, data, firstColumn, lastColumn, deviation, observed)

nxi = this.NumStates;
nf = this.NumForward;
ny = this.NumObserved;
ne = this.NumShocks;
idObserved = this.IdObserved;
idShocks = this.IdShocks;
idStates = this.IdStates;
idBackward = this.IdBackward;
indexCurrent = this.IndexCurrent;
idCurrent = this.IdCurrent;
linxBackward = this.LinxBackward;
linxCurrent = this.LinxCurrent;
linxStep = this.LinxStep;
%linxBackward = sub2ind(size(data.YXEPG), real(idBackward), firstColumn+imag(idBackward));
%linxCurrent = sub2ind(size(data.YXEPG), real(idCurrent), firstColumn+imag(idCurrent));
%linxStep = size(data.YXEPG, 1);
[T, R, K, Z, H, D] = this.FirstOrderSolution{:};

if ne>0
    expectedShocks = this.Expected( data.YXEPG(idShocks, :) );
    unexpectedShocks = this.Unexpected( data.YXEPG(idShocks, :) );
    lastExpectedShock = find(any(expectedShocks~=0, 1), 1, 'last');
    if isempty(lastExpectedShock)
        lastExpectedShock = 0;
    end
    currentForward = size(R, 2)/ne - 1;
    requiredForward = lastExpectedShock - firstColumn;
    if requiredForward>currentForward
        R = model.expandFirstOrder(R, [ ], this.FirstOrderExpansion, requiredForward);
        this.FirstOrderSolution{2} = R;
    end
end

if any(this.IndexLog)
    data.YXEPG(this.IndexLog, :) = log(data.YXEPG(this.IndexLog, :));
end

for t = firstColumn : lastColumn
    % __Endogenous variables__
    Xi_t = T*data.YXEPG(linxBackward-linxStep);
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
    data.YXEPG(linxCurrent) = Xi_t(indexCurrent);

    % __Observables__
    if observed && ny>0
        Y_t = Z*Xi_t(nf+1:end);
        if ne>0
            Y_t = Y_t + H*(expectedShocks(:, t) + unexpectedShocks(:, t));
        end
        if ~deviation
            Y_t = Y_t + D;
        end
        data.YXEPG(idObserved, t) = Y_t;
    end

    % Update linear indexes by one column ahead.
    linxBackward = round(linxBackward + linxStep);
    linxCurrent = round(linxCurrent + linxStep);
end

if any(this.IndexLog)
    data.YXEPG(this.IndexLog, :) = exp(data.YXEPG(this.IndexLog, :));
end

end

