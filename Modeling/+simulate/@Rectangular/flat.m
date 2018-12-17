function flat(this, data)
% flat  Flat rectangular simulation
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;
VEC = @(x) x(:);

%--------------------------------------------------------------------------

[ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
nh = this.NumOfHashEquations;

inxOfY = getIndexByType(this.Quantity, TYPE(1));
inxOfE = getIndexByType(this.Quantity, TYPE(31) , TYPE(32));
inxOfCurrentWithinXi = this.InxOfCurrentWithinXi;
inxOfLog = this.Quantity.InxOfLog;

sizeOfData = size(data.YXEPG);
firstColumn = this.FirstColumn;
lastColumn = this.LastColumn;

linxOfXib = this.LinxOfXib;
linxOfCurrentXi = this.LinxOfCurrentXi;
stepForLinx = size(data.YXEPG, 1);

deviation = this.Deviation;
simulateY = this.SimulateY;

anticipatedE = data.AnticipatedE;
unanticipatedE = data.UnanticipatedE;

lastAnticipatedE = 0;
if ne>0
    if ~data.MixinUnanticipated
        unanticipatedE(:, firstColumn+1:end) = 0;
    end
    lastAnticipatedE = getLastAnticipatedE(data);
end

% Retrieve first-order solution after making sure expansion is sufficient
[T, R, K, Z, H, D, Y] = this.FirstOrderSolution{:};

% Nonlinear add-factors
nlaf = data.NonlinAddfactors;
lastNlaf = 0;
nlafExist = ~isempty(Y) && ~isempty(nlaf) && any(nlaf(:)~=0);
if nlafExist
    lastNlaf = find(any(nlaf~=0, 1), 1, 'last');
    if isempty(lastNlaf)
        lastNlaf = 0;
    end
end

if any(inxOfLog)
    data.YXEPG(inxOfLog, :) = log( data.YXEPG(inxOfLog, :) );
end

% Initial condition
Xi_0 = data.YXEPG(linxOfXib-stepForLinx);

% Required initial conditions already checked for NaNs; here reset any
% remaining (seeming) initial conditions 
Xi_0(isnan(Xi_0)) = 0;

for t = firstColumn : lastColumn
    % __Transition Variables__
    Xi_t = T*Xi_0;

    if ~deviation
        % Add constant
        Xi_t = Xi_t + K;
    end
    
    if ne>0
        % Add expected and unexpected shocks
        if t<=lastAnticipatedE
            ahead = lastAnticipatedE - t + 1;
            combinedE = anticipatedE(:, t:lastAnticipatedE);
            combinedE(:, 1) = combinedE(:, 1) + unanticipatedE(:, t);
            Xi_t = Xi_t + R(:, 1:ahead*ne)*combinedE(:);
        else
            Xi_t = Xi_t + R(:, 1:ne)*unanticipatedE(:, t);
        end
    end

    if t<=lastNlaf
        % Add nonlinear add-factors
        ahead = lastNlaf - t + 1;
        Xi_t = Xi_t + Y(:, 1:ahead*nh)*VEC(nlaf(:, t:lastNlaf));
    end

    % Update current column in data matrix
    data.YXEPG(linxOfCurrentXi) = Xi_t(inxOfCurrentWithinXi);

    % __Observables__
    if simulateY && ny>0
        Y_t = Z*Xi_t(nf+1:end);
        if ~deviation
            % Add constant
            Y_t = Y_t + D;
        end
        if ne>0
            % Add shocks
            Y_t = Y_t + H*(anticipatedE(:, t) + unanticipatedE(:, t));
        end
        % Update current column in data matrix
        data.YXEPG(inxOfY, t) = Y_t;
    end

    % Update linear indexes by one column ahead
    linxOfXib = round(linxOfXib + stepForLinx);
    linxOfCurrentXi = round(linxOfCurrentXi + stepForLinx);

    Xi_0 = data.YXEPG(linxOfXib-stepForLinx);
end

if any(inxOfLog)
    data.YXEPG(inxOfLog, :) = exp( data.YXEPG(inxOfLog, :) );
end

end%

