function multipliers(this, data, anticipate)
% multipliers  Get shock multipliers for one simulation frame
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

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

% Period of last endogenized and last exogenized point within simulation
% columns
anyExogenized = any(data.InxOfExogenizedYX, 1);
lastExogenizedYX = max([0, find(anyExogenized, 1, 'Last')]);
lastEndogenizedE = data.LastEndogenizedE;

inxOfEndogenizedE = data.InxOfEndogenizedE(:, firstColumn:lastEndogenizedE);
inxOfExogenizedYX = data.InxOfExogenizedYX(:, firstColumn:lastExogenizedYX);

if tryExistingMultipliers( )
    return
end

vecEndogenizedE = VEC(inxOfEndogenizedE);
vecExogenizedYX = VEC(inxOfExogenizedYX);
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
idOfAll = 1 : size(data.YXEPG, 1);
idOfYX = idOfAll(data.InxOfYX);
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
    idOfExogenizedYX = idOfYX(data.InxOfExogenizedYX(:, t));
    if isempty(idOfExogenizedYX)
        continue
    end
    addToM = [y; xf; xb];
    % Find the rows in which idOfExogenizedYX occur in idOfYXi
    [~, rows] = ismember(idOfExogenizedYX, idOfYXi);
    addToM = addToM(rows, vecEndogenizedE);
    M = [M; addToM];
end

this.FirstOrderMultipliers = M;
this.MultipliersEndogenizedE = data.InxOfEndogenizedE(:, firstColumn:lastEndogenizedE);
this.MultipliersExogenizedYX = data.InxOfExogenizedYX(:, firstColumn:lastExogenizedYX);

return


    function flag = tryExistingMultipliers( )
        if isempty(this.FirstOrderMultipliers)
            flag = false;
            return
        end
        sizeExogenizedYX = size(inxOfExogenizedYX, 2);
        sizeEndogenizedE = size(inxOfEndogenizedE, 2);
        if sizeExogenizedYX>size(this.MultipliersExogenizedYX, 2) ...
           || sizeEndogenizedE>size(this.MultipliersEndogenizedE, 2)
            flag = false;
           return
        end
        if ~isequal(inxOfExogenizedYX, this.MultipliersExogenizedYX(:, 1:sizeExogenizedYX)) ...
           || ~isequal(inxOfEndogenizedE, this.MultipliersEndogenizedE(:, 1:sizeEndogenizedE))
            flag = false;
            return
        end
        numOfExogenizedYX = nnz(inxOfExogenizedYX);
        numOfEndogenizedE = nnz(inxOfEndogenizedE);
        this.FirstOrderMultipliers = this.FirstOrderMultipliers(1:numOfExogenizedYX, 1:numOfEndogenizedE);
        this.MultipliersExogenizedYX = inxOfExogenizedYX;
        this.MultipliersEndogenizedE = inxOfEndogenizedE;
        flag = true;
   end%
end%

