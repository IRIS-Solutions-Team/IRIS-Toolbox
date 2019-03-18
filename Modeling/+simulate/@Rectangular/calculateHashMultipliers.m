function calculateHashMultipliers(this, data)
% calculateHashMultipliers  Calculate multipliers of hash factors for one simulation frame
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

nh = this.NumOfHashEquations;
window = data.Window;

% Simulation columns
firstColumn = this.FirstColumn;
lastColumnOfWindow = round(firstColumn + window - 1);
lastHashedYX = data.LastHashedYX;

if tryExistingMultipliers( )
    return
end

[ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
idOfYXi = [ this.SolutionVector{1:2} ];
[T, ~, ~, ~, ~, ~, Q] = this.FirstOrderSolution{:};
Tf = T(1:nf, :);
Tb = T(nf+1:end, :);
Qf = Q(1:nf, 1:nh*window);
Qb = Q(nf+1:end, 1:nh*window);

M = zeros(0, nh*window);
xb = zeros(size(Qb));
idOfAll = 1 : size(data.YXEPG, 1);
idOfYX = idOfAll(data.InxOfYX);
for t = firstColumn : lastHashedYX
    xf = Tf*xb;
    xb = Tb*xb;
    if t<=lastColumnOfWindow
        xb = xb + Qb;
        xf = xf + Qf;
        Qb = [zeros(nb, nh), Qb(:, 1:end-nh)];
        Qf = [zeros(nf, nh), Qf(:, 1:end-nh)];
    end
    idOfHashedYX_t = idOfYX(data.InxOfHashedYX(:, t));
    if isempty(idOfHashedYX_t)
        continue
    end
    addToM = [nan(ny, nh*window); xf; xb];
    % Find the rows in which idOfHashedYX_t occur in idOfYXi
    [~, rows] = ismember(idOfHashedYX_t, idOfYXi);
    M = [M; addToM(rows, :)];
end

this.HashMultipliers = M;
this.MultipliersHashedYX = data.InxOfHashedYX(:, firstColumn:lastHashedYX);

return


    function flag = tryExistingMultipliers( )
        if isempty(this.HashMultipliers)
            flag = false;
            return
        end
        inxOfHashedYX = data.InxOfHashedYX(:, firstColumn:lastHashedYX);
        if isequal(this.MultipliersHashedYX, inxOfHashedYX) ...
           && size(this.HashMultipliers,2)==nh*window
            flag = true;
            return
        end
        if window>size(this.MultipliersHashedYX, 2) ...
           || nh*window>size(this.HashMultipliers, 2)
            flag = false;
            return
        end
        if ~isequal(inxOfHashedYX, this.MultipliersHashedYX(:, 1:window))
            flag = false;
            return
        end
        numOfHashedYX = nnz(inxOfHashedYX);
        this.HashMultipliers = this.HashMultipliers(1:numOfHashedYX, 1:nh*window);
        this.MultipliersHashedYX = inxOfHashedYX;
        flag = true;
   end%
end%

