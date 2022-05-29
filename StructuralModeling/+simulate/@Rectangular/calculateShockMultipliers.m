% calculateShockMultipliers  Get shock multipliers for one simulation frame
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function calculateShockMultipliers(this, data, anticipate)

try
    anticipate;
catch
    anticipate = true;
end

%--------------------------------------------------------------------------

[numY, ~, numXiB, numXiF, numE] = sizeSolution(this);
idYXi = [ this.Vector.Solution{1:2} ];
[T, R, ~, Z, H, ~, Q] = this.FirstOrderSolution{:};
Tf = T(1:numXiF, :);
Tb = T(numXiF+1:end, :);
if ~anticipate
    R(:, numE+1:end) = 0;
end

% Simulation columns
firstColumn = this.FirstColumn;

% Period of last endogenized and last exogenized point within simulation
% columns
lastExogenizedYX = data.LastExogenizedYX;
lastEndogenizedE = data.LastEndogenizedE;

inxEndogenizedE = data.InxEndogenizedE;
inxExogenizedYX = data.InxExogenizedYX;

inxEndogenizedWithinE = inxEndogenizedE(data.InxE, firstColumn:lastEndogenizedE);
inxExogenizedWithinYX = inxExogenizedYX(data.InxYX, :);

if hereTryExistingMultipliers( )
    return
end

vecEndogenizedE = reshape(inxEndogenizedWithinE, [ ], 1);
numEndogenizedE = nnz(vecEndogenizedE);

numPeriods = round(lastEndogenizedE - firstColumn + 1);
Rf = R(1:numXiF, 1:numE*numPeriods);
Rb = R(numXiF+1:end, 1:numE*numPeriods);
H = [H, zeros(numY, numE*(numPeriods-1))];

M = zeros(0, numEndogenizedE);
xb = zeros(size(Rb));
idYX = find(data.InxYX);
for t = firstColumn : lastExogenizedYX
    %
    % Update transition variables
    %
    xf = Tf*xb;
    xb = Tb*xb;
    if t<=lastEndogenizedE
        xb = xb + Rb;
        xf = xf + Rf;
        Rb = [zeros(numXiB, numE), Rb(:, 1:end-numE)];
        Rf = [zeros(numXiF, numE), Rf(:, 1:end-numE)];
    end

    %
    % Calculate measurement variables
    %
    y = Z*xb;
    if t<=lastEndogenizedE
        y = y + H;
        H = [zeros(numY, numE), H(:, 1:end-numE)];
    end

    %
    % No exogenized YX in this column, continue immediately
    %
    if ~any(inxExogenizedWithinYX(:, t))
        continue
    end

    idExogenizedYX = idYX(inxExogenizedWithinYX(:, t));

    addToM = [y; xf; xb];
    % Find the rows in which idExogenizedYX occur in idYXi
    [~, rows] = ismember(idExogenizedYX, idYXi);
    M = [M; addToM(rows, vecEndogenizedE)];
end

this.FirstOrderMultipliers = M;
if this.Method==solver.Method.SELECTIVE
    hereCalculateKalmanGain( );
end
this.MultipliersEndogenizedE = inxEndogenizedE(:, firstColumn:lastEndogenizedE);
this.MultipliersExogenizedYX = inxExogenizedYX(:, firstColumn:lastExogenizedYX);

return

    function flag = hereTryExistingMultipliers( )
        if isempty(this.FirstOrderMultipliers)
            flag = false;
            return
        end
        numColumnsExogenizedYX = size(inxExogenizedYX, 2);
        numColumnsEndogenizedE = size(inxEndogenizedE, 2);
        if numColumnsExogenizedYX>size(this.MultipliersExogenizedYX, 2) ...
           || numColumnsEndogenizedE>size(this.MultipliersEndogenizedE, 2)
            flag = false;
           return
        end
        if ~isequal(inxExogenizedYX, this.MultipliersExogenizedYX(:, 1:numColumnsExogenizedYX)) ...
           || ~isequal(inxEndogenizedE, this.MultipliersEndogenizedE(:, 1:numColumnsEndogenizedE))
            flag = false;
            return
        end
        numExogenizedYX = nnz(inxExogenizedYX);
        numEndogenizedE = nnz(inxEndogenizedE);
        if ~isequal(size(this.FirstOrderMultipliers), [numExogenizedYX, numEndogenizedE]);
            this.FirstOrderMultipliers = this.FirstOrderMultipliers(1:numExogenizedYX, 1:numEndogenizedE);
            if this.Method==solver.Method.SELECTIVE
                this.KalmanGain = hereCalculateKalmanGain( );
            end
        end
        this.MultipliersExogenizedYX = inxExogenizedYX;
        this.MultipliersEndogenizedE = inxEndogenizedE;
        flag = true;
    end%


    function kalmanGain = hereCalculateKalmanGain( )
        numExogenizedYX = nnz(inxExogenizedYX);
        numEndogenizedE = nnz(inxEndogenizedE);
        if numExogenizedYX==numEndogenizedE && ~strcmpi(this.PlanMethod, 'Condition')
            kalmanGain = inv(this.FirstOrderMultipliers);
        else
            F = this.FirstOrderMultipliers*data.Sigma*this.FirstOrderMultipliers';
            kalmanGain = data.Sigma*this.FirstOrderMultipliers'/F;
        end
    end%
end%

