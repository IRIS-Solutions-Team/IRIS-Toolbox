function getMultipliers(this)

ny = this.NumOfObserved;
nf = this.NumOfForward;
nb = this.NumOfBackward;
idOfAll = [this.IdOfObserved; this.IdOfStates];

% Simulation columns
firstColumn = this.FirstColumn;
lastColumn = this.LastColumn;
numOfPeriods = lastColumn - firstColumn + 1;

% Period of last endogenized and last exogenized point within simulation
% columns
indexOfExogenized = this.IndexOfExogenized(:, firstColumn:lastColumn);
indexOfEndogenized = this.IndexOfEndogenized(:, firstColumn:lastColumn);
indexOfAnyExogenized = any(indexOfExogenized, 1);
indexOfAnyEndogenized = any(indexOfEndogenized, 1);
periodOfLastExogenized = max([0, find(indexOfAnyExogenized, 1, 'Last')]);
periodOfLastEndogenized = max([0, find(indexOfAnyEndogenized, 1, 'Last')]);

vecIndexOfEndogenized = indexOfEndogenized(:);

[T, R, K, Z, H, D] = this.FirstOrderSolution{:};
Tf = T(1:nf, :);
Tb = T(1:nb, :);
Rf = R(1:nf, 1:ne*numOfPeriods);
Rb = R(nf+1:end, 1:ne*numOfPeriods);
H = [H, zeros(ny, ne*(numOfPeriods-1))];

M = zeros(0, nnz(vecIndexOfEndogenized));
xb = zeros(size(Rb));
for t = 1 : periodOfLastExogenized
    xf = Tf*xb;
    xb = Tb*xb;
    y = Z*xb;
    if t<=periodOfLastEndogenized
        xb = xb + Rb;
        xf = xf + Rf;
        y = y + H;
        Rb = [zeros(nb, ne), Rb(:, 1:end-ne)];
        Rf = [zeros(nb, ne), Rf(:, 1:end-ne)];
        H = [zeros(nb, ne), H(:, 1:end-ne)];
    end
    addToM = [y; xf; xb];
    idOfExogenized = find(indexOfExogenized(:, t));
    if isempty(idOfExogenized)
        continue
    end
    [~, rows] = ismember(idOfExogenized, idOfAll);
    addToM = addToM(rows, vecIndexOfEndogenized);
    M = [M; addToM];
end

end%

