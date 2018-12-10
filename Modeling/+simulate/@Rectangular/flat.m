function flat(this, data, nlaf)

vec = @(x) x(:);

[ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
nh = this.NumOfHashEquations;

posOfY = this.IdOfObserved;
posOfE = this.IdOfShocks;
inxOfCurrentWithinXi = this.InxOfCurrentWithinXi;

sizeOfData = size(data.YXEPG);
firstColumn = this.FirstColumn;
lastColumn = this.LastColumn;

linxOfXib = this.LinxOfXib;
linxOfCurrentXi = this.LinxOfCurrentXi;
stepForLinx = this.NumOfQuantities;

deviation = this.Deviation;
simulateObserved = this.SimulateObserved;

[T, R, K, Z, H, D, Y] = this.FirstOrderSolution{:};

if ne>0
    expectedShocks = this.RetrieveExpected( data.YXEPG(posOfE, :) );
    unexpectedShocks = this.RetrieveUnexpected( data.YXEPG(posOfE, :) );
    lastExpectedShock = find(any(expectedShocks~=0, 1), 1, 'last');
    if isempty(lastExpectedShock)
        lastExpectedShock = 0;
    end
    requiredForward = lastExpectedShock - firstColumn;
end

% Nonlinear addfactors
lastNlaf = 0;
nlafExist = ~isempty(Y) && ~isempty(nlaf) && any(nlaf(:)~=0);
if nlafExist
    lastNlaf = find(any(nlaf~=0, 1), 1, 'last');
    if isempty(lastNlaf)
        lastNlaf = 0;
    end
end

if any(this.InxOfLog)
    data.YXEPG(this.InxOfLog, :) = log( data.YXEPG(this.InxOfLog, :) );
end

for t = firstColumn : lastColumn
    % __Endogenous variables__
    Xi_t = T*data.YXEPG(linxOfXib-stepForLinx);

    if ~deviation
        % Add constant
        Xi_t = Xi_t + K;
    end
    
    if ne>0
        % Add expected and unexpected shocks
        if t<=lastExpectedShock
            ahead = lastExpectedShock - t + 1;
            shocks = expectedShocks(:, t:lastExpectedShock);
            shocks(:, 1) = shocks(:, 1) + unexpectedShocks(:, t);
            Xi_t = Xi_t + R(:, 1:ahead*ne)*shocks(:);
        else
            Xi_t = Xi_t + R(:, 1:ne)*unexpectedShocks(:, t);
        end
    end

    if t<=lastNlaf
        % Add nonlinear add-factors
        ahead = lastNlaf - t + 1;
        Xi_t = Xi_t + Y(:, 1:ahead*nh)*vec(nlaf(:, t:lastNlaf));
    end

    % Update current column in data matrix
    data.YXEPG(linxOfCurrentXi) = Xi_t(inxOfCurrentWithinXi);

    % __Observables__
    if simulateObserved && ny>0
        Y_t = Z*Xi_t(nf+1:end);
        if ~deviation
            % Add constant
            Y_t = Y_t + D;
        end
        if ne>0
            % Add shocks
            Y_t = Y_t + H*(expectedShocks(:, t) + unexpectedShocks(:, t));
        end
        % Update current column in data matrix
        data.YXEPG(posOfY, t) = Y_t;
    end

    % Update linear indexes by one column ahead
    linxOfXi = round(linxOfXi + stepForLinx);
    linxOfCurrentXi = round(linxOfCurrentXi + stepForLinx);
end

if any(this.InxOfLog)
    data.YXEPG(this.InxOfLog, :) = exp( data.YXEPG(this.InxOfLog, :) );
end

end%

