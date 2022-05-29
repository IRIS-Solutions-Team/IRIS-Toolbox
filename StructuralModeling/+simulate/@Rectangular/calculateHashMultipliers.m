% calculateHashMultipliers  Calculate multipliers of hash factors for one simulation frame
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function calculateHashMultipliers(this, data)

nh = this.NumHashEquations;
window = data.Window;

% Simulation columns
firstColumn = this.FirstColumn;
lastColumnWindow = round(firstColumn + window - 1);
lastHashedYX = data.LastHashedYX;

if tryExistingMultipliers( )
    return
end

[numY, ~, numXiB, numXiF] = sizeSolution(this);
idYXi = [ this.Vector.Solution{1:2} ];
[T, ~, ~, ~, ~, ~, Q] = this.FirstOrderSolution{:};
Tf = T(1:numXiF, :);
Tb = T(numXiF+1:end, :);
Qf = Q(1:numXiF, 1:nh*window);
Qb = Q(numXiF+1:end, 1:nh*window);

% First, find the rows in the multiplier matrix that will be filled in
idAll = 1 : size(data.YXEPG, 1);
idYX = idAll(data.InxYX);
rows = cell(1, lastHashedYX);
numRows = zeros(1, lastHashedYX);
for t = firstColumn : lastHashedYX
    idHashedYX_t = idYX(data.InxHashedYX(:, t));
    if isempty(idHashedYX_t)
        continue
    end
    % Find the rows in which idHashedYX_t occur in idYXi
    [~, rows{t}] = ismember(idHashedYX_t, idYXi);
    numRows(t) = numel(rows{t});
end

% Second, preallocate the multiplier matrix, and calculate the matrix
M = zeros(sum(numRows), nh*window);
xb = zeros(size(Qb));
countRows = 0;
for t = firstColumn : lastHashedYX
    xf = Tf*xb;
    xb = Tb*xb;
    if t<=lastColumnWindow
        xb = xb + Qb;
        xf = xf + Qf;
        Qb = [zeros(numXiB, nh), Qb(:, 1:end-nh)];
        Qf = [zeros(numXiF, nh), Qf(:, 1:end-nh)];
    end
    if isempty(rows{t})
        continue
    end
    addToM = [nan(numY, nh*window); xf; xb];
    M(countRows+(1:numRows(t)), :) = addToM(rows{t}, :);
    countRows = countRows + numRows(t);
end

this.HashMultipliers = M;
this.MultipliersHashedYX = data.InxHashedYX(:, firstColumn:lastHashedYX);

return


    function flag = tryExistingMultipliers( )
        if isempty(this.HashMultipliers)
            flag = false;
            return
        end
        inxHashedYX = data.InxHashedYX(:, firstColumn:lastHashedYX);
        if isequal(this.MultipliersHashedYX, inxHashedYX) ...
           && size(this.HashMultipliers,2)==nh*window
            flag = true;
            return
        end
        if window>size(this.MultipliersHashedYX, 2) ...
           || nh*window>size(this.HashMultipliers, 2)
            flag = false;
            return
        end
        if ~isequal(inxHashedYX, this.MultipliersHashedYX(:, 1:window))
            flag = false;
            return
        end
        numHashedYX = nnz(inxHashedYX);
        this.HashMultipliers = this.HashMultipliers(1:numHashedYX, 1:nh*window);
        this.MultipliersHashedYX = inxHashedYX;
        flag = true;
   end%
end%

