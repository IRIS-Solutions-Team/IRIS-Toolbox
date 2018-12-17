function multipliers(this, data, anticipate)
% multipliers  Get shock multipliers for one simulation frame
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

VEC = @(x) x(:);

try
    anticipate;
catch
    anticipate = true;
end

%--------------------------------------------------------------------------

[ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
idOfYXi = [ this.SolutionVector{1:2} ];

% Simulation columns
firstColumn = this.FirstColumn;
lastColumn = this.LastColumn;
numOfPeriods = lastColumn - firstColumn + 1;

% Period of last endogenized and last exogenized point within simulation
% columns
anyExogenized = any(data.Exogenized, 1);
lastExogenizedYX = max([0, find(anyExogenized, 1, 'Last')]);
lastEndogenizedE = getLastEndogenizedE(data);

endogenizedE = data.Endogenized(data.InxOfE, firstColumn:lastEndogenizedE);
exogenizedYX = data.Exogenized(data.InxOfYX, firstColumn:lastExogenizedYX);

if tryExistingMultipliers( )
    return
end

vecEndogenizedE = VEC(endogenizedE);
vecExogenizedYX = VEC(exogenizedYX);
numOfEndogenizedE = nnz(vecEndogenizedE);

[T, R, K, Z, H, D] = this.FirstOrderSolution{:};
Tf = T(1:nf, :);
Tb = T(nf+1:end, :);
if ~anticipate
    R(:, ne+1:end) = 0;
end

numOfPeriods = round(lastEndogenizedE - firstColumn + 1);
Rf = R(1:nf, 1:ne*numOfPeriods);
Rb = R(nf+1:end, 1:ne*numOfPeriods);
H = [H, zeros(ny, ne*(numOfPeriods-1))];

M = zeros(0, numOfEndogenizedE);
xb = zeros(size(Rb));
for t = firstColumn : lastExogenizedYX
    xf = Tf*xb;
    xb = Tb*xb;
    y = Z*xb;
    if t<=lastEndogenizedE
        xb = xb + Rb;
        xf = xf + Rf;
        y = y + H;
        Rb = [zeros(nb, ne), Rb(:, 1:end-ne)];
        Rf = [zeros(nf, ne), Rf(:, 1:end-ne)];
        H = [zeros(ny, ne), H(:, 1:end-ne)];
    end
    idOfExogenized = find(data.Exogenized(:, t));
    if isempty(idOfExogenized)
        continue
    end
    addToM = [y; xf; xb];
    % Find the rows in which idOfExogenized occur in idOfYXi
    [~, rows] = ismember(idOfExogenized, idOfYXi);
    addToM = addToM(rows, vecEndogenizedE);
    M = [M; addToM];
end

this.FirstOrderMultipliers = M;
this.MultipliersEndogenizedE = data.Endogenized(data.InxOfE, firstColumn:lastEndogenizedE);
this.MultipliersExogenizedYX = data.Exogenized(data.InxOfYX, firstColumn:lastExogenizedYX);

return


    function flag = tryExistingMultipliers( )
        if isempty(this.FirstOrderMultipliers)
            flag = false;
            return
        end
        sizeExogenizedYX = size(exogenizedYX, 2);
        sizeEndogenizedE = size(endogenizedE, 2);
        if sizeExogenizedYX>size(this.MultipliersExogenizedYX, 2) ...
           || sizeEndogenizedE>size(this.MultipliersEndogenizedE, 2)
            flag = false;
           return
        end
        if ~isequal(exogenizedYX, this.MultipliersExogenizedYX(:, 1:sizeExogenizedYX)) ...
           || ~isequal(endogenizedE, this.MultipliersEndogenizedE(:, 1:sizeEndogenizedE))
            flag = false;
            return
        end
        numOfExogenizedYX = nnz(exogenizedYX);
        numOfEndogenizedE = nnz(endogenizedE);
        this.FirstOrderMultipliers = this.FirstOrderMultipliers(1:numOfExogenizedYX, 1:numOfEndogenizedE);
        this.MultipliersExogenizedYX = exogenizedYX;
        this.MultipliersEndogenizedE = endogenizedE;
        flag = true;
   end%
end%

