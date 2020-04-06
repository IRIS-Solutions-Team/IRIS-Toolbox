function calculateShockMultipliers(this, data, anticipate)
% calculateShockMultipliers  Get shock multipliers for one simulation frame
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

try
    anticipate;
catch
    anticipate = true;
end

%--------------------------------------------------------------------------

[numY, ~, numXiB, numXiF, numE] = sizeOfSolution(this);
idYXi = [ this.SolutionVector{1:2} ];
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
if isempty(data.InxOfExogenizedYX)
    lastExogenizedYX = 0;
else
    anyExogenized = any(data.InxOfExogenizedYX, 1);
    lastExogenizedYX = max([0, find(anyExogenized, 1, 'Last')]);
end
lastEndogenizedE = data.LastEndogenizedE;

inxEndogenizedE = data.InxOfEndogenizedE(:, firstColumn:lastEndogenizedE);
inxExogenizedYX = data.InxOfExogenizedYX(:, firstColumn:lastExogenizedYX);

if tryExistingMultipliers( )
    return
end

vecEndogenizedE = inxEndogenizedE(:);
numEndogenizedE = nnz(vecEndogenizedE);

numPeriods = round(lastEndogenizedE - firstColumn + 1);
Rf = R(1:numXiF, 1:numE*numPeriods);
Rb = R(numXiF+1:end, 1:numE*numPeriods);
H = [H, zeros(numY, numE*(numPeriods-1))];

M = zeros(0, numEndogenizedE);
xb = zeros(size(Rb));
idYX = find(data.InxOfYX);
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

    idExogenizedYX = idYX(data.InxOfExogenizedYX(:, t));
    if isempty(idExogenizedYX)
        continue
    end
    addToM = [y; xf; xb];
    % Find the rows in which idExogenizedYX occur in idYXi
    [~, rows] = ismember(idExogenizedYX, idYXi);
    M = [M; addToM(rows, vecEndogenizedE)];
end

this.FirstOrderMultipliers = M;
if this.Method==solver.Method.SELECTIVE
    hereCalculateKalmanGain( );
end
this.MultipliersEndogenizedE = data.InxOfEndogenizedE(:, firstColumn:lastEndogenizedE);
this.MultipliersExogenizedYX = data.InxOfExogenizedYX(:, firstColumn:lastExogenizedYX);

return


    function flag = tryExistingMultipliers( )
        if isempty(this.FirstOrderMultipliers)
            flag = false;
            return
        end
        sizeExogenizedYX = size(inxExogenizedYX, 2);
        sizeEndogenizedE = size(inxEndogenizedE, 2);
        if sizeExogenizedYX>size(this.MultipliersExogenizedYX, 2) ...
           || sizeEndogenizedE>size(this.MultipliersEndogenizedE, 2)
            flag = false;
           return
        end
        if ~isequal(inxExogenizedYX, this.MultipliersExogenizedYX(:, 1:sizeExogenizedYX)) ...
           || ~isequal(inxEndogenizedE, this.MultipliersEndogenizedE(:, 1:sizeEndogenizedE))
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

