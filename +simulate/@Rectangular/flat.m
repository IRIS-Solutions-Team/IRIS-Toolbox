function flat(this, data, from, to, deviation)

nxi = this.NumOfStates;
nf = this.NumOfForward;
ny = this.NumOfObserved;
ne = this.NumOfShocks;
idOfShocks = this.IdOfShocks;
idOfBackward = this.IdOfStates(nf+1:end);
[T, R, K, Z, H, D] = this.SolutionMatrices{:};

firstColumn = between(data.FirstDate, from);
lastColumn = between(data.FirstDate, to);

lastExpectedShock = find(any(data.YXEPG(idOfShocks, :)~=0, 2));
if isempty(lastExpectedShock)
    lastExpectedShock = 0;
end

linxOfStates = sub2ind(size(data.YXEPG), real(this.IdOfStates), firstColumn+imag(this.IdOfStates));
linxOfBackward = linxOfStates(nf+1:end);
indexOfCurrent = imag(this.IdOfStates)==0;
linxOfCurrent = linxOfStates(indexOfCurrent);
linxStep = size(data.YXEPG, 1);

for t = firstColumn : lastColumn
    Xi_t = T*data.YXEPG(linxOfBackward-linxStep);
    if ~deviation
        Xi_t = Xi_t + K;
    end
    if t<=lastExpectedShock
        ahead = lastExpectedShock - t + 1;
        Xi_t = Xi_t + R(:, 1:ahead*ne)*data.YXEPG(idOfShocks, t:lastExpectedShock);
    end
    data.YXEPG(linxOfCurrent) = Xi_t(indexOfCurrent);

    % Update linear indexes by one column ahead.
    linxOfStates = round(linxOfStates + linxStep);
    linxOfBackward = round(linxOfBackward + linxStep);
    linxOfCurrent = round(linxOfCurrent + linxStep);
end

if ny>0
    columnRange = firstColumn : lastColumn;
    Y = Z*this.Data(idOfBackward, columnRange) + H*this.Data(idOfShocks, columnRange);
    if ~deviation
        Y = bsxfun(@plus, Y, D);
    end
    this.Data(idOfObserved, columnRange) = Y;
end

end

