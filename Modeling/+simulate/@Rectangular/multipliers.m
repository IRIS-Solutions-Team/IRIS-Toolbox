function multipliers(this, anticipate)
% multipliers  Get shock multipliers for one simulation frame
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

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
inxOfExogenized = this.InxOfExogenized(:, firstColumn:lastColumn);
inxOfEndogenized = this.InxOfEndogenizedShocks(:, firstColumn:lastColumn);
inxOfAnyExogenized = any(inxOfExogenized, 1);
inxOfAnyEndogenized = any(inxOfEndogenized, 1);
periodOfLastExogenized = max([0, find(inxOfAnyExogenized, 1, 'Last')]);
periodOfLastEndogenized = max([0, find(inxOfAnyEndogenized, 1, 'Last')]);

vecInxOfEndogenized = inxOfEndogenized(:);
numOfEndogenized = nnz(vecInxOfEndogenized);

[T, R, K, Z, H, D] = this.FirstOrderSolution{:};
Tf = T(1:nf, :);
Tb = T(1:nb, :);
if ~anticipate
    R(:, ne+1:end) = 0;
end
Rf = R(1:nf, 1:ne*numOfPeriods);
Rb = R(nf+1:end, 1:ne*numOfPeriods);
H = [H, zeros(ny, ne*(numOfPeriods-1))];

M = zeros(0, numOfEndogenized);
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
    idOfExogenized = find(inxOfExogenized(:, t));
    if isempty(idOfExogenized)
        continue
    end
    addToM = [y; xf; xb];
    % Find the rows in which idOfExogenized occur in idOfAll
    [~, rows] = ismember(idOfExogenized, idOfAll);
    addToM = addToM(rows, vecInxOfEndogenized);
    M = [M; addToM];
end

end%

