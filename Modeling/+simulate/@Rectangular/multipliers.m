function multipliers(this, scenario, anticipate)
% multipliers  Get shock multipliers for one simulation frame
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

[ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
idOfYXi = [ this.SolutionVector{1:2} ];

% Simulation columns
firstColumn = this.FirstColumn;
lastColumn = this.LastColumn;
numOfPeriods = lastColumn - firstColumn + 1;

% Period of last endogenized and last exogenized point within simulation
% columns
inxOfAnyExogenizedYX = any(this.InxOfExogenizedYX(:, firstColumn:lastColumn), 1);
inxOfAnyEndogenizedE = any(this.InxOfEndogenizedE(:, firstColumn:lastColumn), 1);
periodOfLastExogenizedYX = max([0, find(inxOfAnyExogenizedYX, 1, 'Last')]);
periodOfLastEndogenizedE = max([0, find(inxOfAnyEndogenizedE, 1, 'Last')]);

vecInxOfEndogenizedE = inxOfEndogenized(:);
numOfEndogenized = nnz(vecInxOfEndogenizedE);

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
for t = 1 : periodOfLastExogenizedYX
    xf = Tf*xb;
    xb = Tb*xb;
    y = Z*xb;
    if t<=periodOfLastEndogenizedE
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
    % Find the rows in which idOfExogenized occur in idOfYXi
    [~, rows] = ismember(idOfExogenized, idOfYXi);
    addToM = addToM(rows, vecInxOfEndogenizedE);
    M = [M; addToM];
end

end%

