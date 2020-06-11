function flat(this, data)
% flat  Flat rectangular simulation

% Backend [IrisToolbox] methodk
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

[ny, nxi, nb, nf, ne, ng] = sizeOfSolution(this);
nh = this.NumOfHashEquations;
YXEPG = data.YXEPG;

inxY = getIndexByType(this.Quantity, TYPE(1));
inxE = getIndexByType(this.Quantity, TYPE(31) , TYPE(32));
inxCurrentWithinXi = this.InxOfCurrentWithinXi;
inxLog = this.Quantity.InxLog;

sizeData = size(YXEPG);
firstColumnToRun = this.FirstColumn;
lastColumnToRun = this.LastColumn;
columnsToRun = firstColumnToRun : lastColumnToRun;
sparseShocks = this.SparseShocks;

linxXib = this.LinxOfXib;
linxCurrentXi = this.LinxOfCurrentXi;
stepForLinx = size(YXEPG, 1);

deviation = this.Deviation;
simulateY = this.SimulateY && ny>0;
needsEvalTrends = this.NeedsEvalTrends;

anticipatedE = data.AnticipatedE;
unanticipatedE = data.UnanticipatedE;
lastAnticipatedE = 0;
lastUnanticipatedE = 0;
if isempty(anticipatedE) && isempty(unanticipatedE)
    ne = 0;
elseif ne>0
    if data.MixinUnanticipated
        lastUnanticipatedE = data.LastUnanticipatedE;
    else
        lastUnanticipatedE = min(data.LastUnanticipatedE, firstColumnToRun);
    end
    lastAnticipatedE = data.LastAnticipatedE;
end

% Retrieve first-order solution after making sure expansion is sufficient
[T, R, K, Z, H, D, Q] = this.FirstOrderSolution{:};
R0 = R(:, 1:ne);
lenR = size(R, 2);

% Nonlinear add-factors
nlaf = data.NonlinAddf;
lastNlaf = 0;
existsNlaf = ~isempty(Q) && ~isempty(nlaf) && any(nlaf(:)~=0);
if existsNlaf
    lastNlaf = find(any(nlaf~=0, 1), 1, 'last');
    if isempty(lastNlaf)
        lastNlaf = 0;
    end
    Q = Q(:, 1:(lastNlaf-firstColumnToRun+1)*nh);
    lenQ = size(Q, 2);
end

if any(inxLog)
    YXEPG(inxLog, :) = log(YXEPG(inxLog, :));
end

% Initial condition
linxInit = linxXib - stepForLinx;
if isempty(data.ForceInit)
    % If a linxInit element is negative, this means it is a lag preceding
    % the actual minimum lag in the transition equation; e.g. because it
    % was created as an artifical lag for a measurement equation. No
    % initial condition is needed.
    inxBeforeActual = reshape(linxInit<1, 1, [ ]);
    Xib_0 = zeros(numel(linxInit), 1);
    Xib_0(~inxBeforeActual) = YXEPG(linxInit(~inxBeforeActual));
    inxZeroEffect = reshape(all(T==0, 1), [ ], 1);
    inxReset = inxZeroEffect & ~isfinite(Xib_0);
else
    Xib_0 = reshape(data.ForceInit, [ ], 1);
    YXEPG(linxInit) = Xib_0;
end

% Required initial conditions already checked for NaNs; here reset any
% remaining (seeming) initial conditions 
Xib_0(isnan(Xib_0)) = 0;

if simulateY
    Xb = nan(nxi, sizeData(2));
    E = nan(ne, sizeData(2));
end


% /////////////////////////////////////////////////////////////////////////
for t = columnsToRun
    %
    % Transition Equations
    %
    Xi_t = T*Xib_0;

    if ~deviation
        % Add constant
        Xi_t = Xi_t + K;
    end
    
    if ne>0
        % Add expected and unexpected shocks
        if t<=lastUnanticipatedE
            Xi_t = Xi_t + R0*unanticipatedE(:, t);
        end
        if t<=lastAnticipatedE
            vecAnticipatedE_t = anticipatedE(:, t:lastAnticipatedE);
            vecAnticipatedE_t = vecAnticipatedE_t(:);
            lenToAdd = lenR - numel(vecAnticipatedE_t);
            vecAnticipatedE_t = [vecAnticipatedE_t; zeros(lenToAdd, 1)];
            if sparseShocks
                vecAnticipatedE_t = sparse(vecAnticipatedE_t);
            end
            Xi_t = Xi_t + R*vecAnticipatedE_t;
        end
    end

    if t<=lastNlaf
        % Add nonlinear add-factors
        nlaf_t = nlaf(:, t:lastNlaf);
        nlaf_t = nlaf_t(:);
        lenToAdd = lenQ - numel(nlaf_t);
        nlaf_t = [nlaf_t; zeros(lenToAdd, 1)];
        Xi_t = Xi_t + Q*nlaf_t;
    end

    % Update current column in data matrix
    YXEPG(linxCurrentXi) = Xi_t(inxCurrentWithinXi);
    if this.UpdateEntireXib
        YXEPG(linxXib) = Xi_t(nf+1:end);
    end

    %
    % Measurement Equations
    %
    if simulateY
        Y_t = Z*Xi_t(nf+1:end, :);
        if ~deviation
            % Add constant
            Y_t = Y_t + D;
        end
        if ne>0 
            % Add shocks
            E_t = anticipatedE(:, t);
            if t<=lastUnanticipatedE
                E_t = E_t + unanticipatedE(:, t);
            end
            Y_t = Y_t + H*E_t;
        end
        % Update current column in data matrix
        YXEPG(inxY, t) = Y_t;
    end

    % Update linear indexes by one column ahead
    linxXib = round(linxXib + stepForLinx);
    linxCurrentXi = round(linxCurrentXi + stepForLinx);

    Xib_0 = YXEPG(linxXib-stepForLinx);
end

%
% Deterministic Trends in Measurement Equations
% 
if simulateY && needsEvalTrends
    YXEPG(inxY, columnsToRun) = ...
        YXEPG(inxY, columnsToRun) + data.Trends(:, columnsToRun);
end

if any(inxLog)
    YXEPG(inxLog, :) = exp(YXEPG(inxLog, :));
end

data.YXEPG = YXEPG;

end%

