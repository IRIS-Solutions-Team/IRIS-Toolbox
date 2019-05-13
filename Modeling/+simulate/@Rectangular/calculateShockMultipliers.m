function calculateShockMultipliers(this, data, anticipate)
% calculateShockMultipliers  Get shock multipliers for one simulation frame
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

try
    anticipate;
catch
    anticipate = true;
end

%--------------------------------------------------------------------------

[ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
idOfYXi = [ this.SolutionVector{1:2} ];
[T, R, ~, Z, H, ~, Q] = this.FirstOrderSolution{:};
Tf = T(1:nf, :);
Tb = T(nf+1:end, :);
if ~anticipate
    R(:, ne+1:end) = 0;
end

% Simulation columns
firstColumn = this.FirstColumn;

% Period of last endogenized and last exogenized point within simulation
% columns
if isempty(data.InxOfExogenizedYX)
    lastExogenizedYX = 0;
else
    anyExogenized = any(data.InxOfExogenizedYX, 1);
    lastExogenizedYX = max([0, find(anyExogenized, 1, 'Last')]);
end
lastEndogenizedE = data.LastEndogenizedE;

inxOfEndogenizedE = data.InxOfEndogenizedE(:, firstColumn:lastEndogenizedE);
inxOfExogenizedYX = data.InxOfExogenizedYX(:, firstColumn:lastExogenizedYX);

if tryExistingMultipliers( )
    return
end

vecEndogenizedE = inxOfEndogenizedE(:);
numOfEndogenizedE = nnz(vecEndogenizedE);

numOfPeriods = round(lastEndogenizedE - firstColumn + 1);
Rf = R(1:nf, 1:ne*numOfPeriods);
Rb = R(nf+1:end, 1:ne*numOfPeriods);
H = [H, zeros(ny, ne*(numOfPeriods-1))];

M = zeros(0, numOfEndogenizedE);
xb = zeros(size(Rb));
idOfYX = find(data.InxOfYX);
for t = firstColumn : lastExogenizedYX
    xf = Tf*xb;
    xb = Tb*xb;
    y = Z*xb;
    if t<=lastEndogenizedE
        xb = xb + Rb;
        xf = xf + Rf;
        Rb = [zeros(nb, ne), Rb(:, 1:end-ne)];
        Rf = [zeros(nf, ne), Rf(:, 1:end-ne)];
        y = y + H;
        H = [zeros(ny, ne), H(:, 1:end-ne)];
    end
    idOfExogenizedYX = idOfYX(data.InxOfExogenizedYX(:, t));
    if isempty(idOfExogenizedYX)
        continue
    end
    addToM = [y; xf; xb];
    % Find the rows in which idOfExogenizedYX occur in idOfYXi
    [~, rows] = ismember(idOfExogenizedYX, idOfYXi);
    M = [M; addToM(rows, vecEndogenizedE)];
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

