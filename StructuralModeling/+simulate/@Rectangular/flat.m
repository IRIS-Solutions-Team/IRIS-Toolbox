% flat  Flat rectangular simulation
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function flat(this, data)

[ny, nxi, nb, nf, ne, ng] = sizeSolution(this);
nh = this.NumHashEquations;
YXEPG = data.YXEPG;

inxY = getIndexByType(this.Quantity, 1);
inxE = getIndexByType(this.Quantity, 31, 32);
inxCurrentWithinXi = this.InxOfCurrentWithinXi;
inxLog = this.Quantity.InxLog;

sizeData = size(YXEPG);
firstColumnToRun = this.FirstColumn;
lastColumnToRun = this.LastColumn;
columnsToRun = firstColumnToRun : lastColumnToRun;
sparseShocks = this.SparseShocks;
ignoreShocks = data.IgnoreShocks;

linxXib = this.LinxOfXib;
linxCurrentXi = this.LinxOfCurrentXi;
stepForLinx = size(YXEPG, 1);

deviation = this.Deviation;
simulateY = this.SimulateY && ny>0;

if ignoreShocks
    ne = 0;
end


% Retrieve first-order solution after making sure expansion is sufficient
[T, R, K, Z, H, D, Q] = this.FirstOrderSolution{:};
R0 = R(:, 1:ne);
lenR = size(R, 2);


lastAnticipatedE = 0;
lastUnanticipatedE = 0;
if ne>0
    if this.HasLeads
        % Forward looking model
        anticipatedE = data.AnticipatedE(data.InxE, :);
        unanticipatedE = data.UnanticipatedE(data.InxE, :);
        if data.MixinUnanticipated
            lastUnanticipatedE = data.LastUnanticipatedE;
        else
            lastUnanticipatedE = min(data.LastUnanticipatedE, firstColumnToRun);
        end
        lastAnticipatedE = data.LastAnticipatedE;
    else
        % Backward looking model; combine anticipated and unanticipated
        % shocks and handle them as unanticipated to accelerate the
        % simulation
        unanticipatedE = data.UnanticipatedE(data.InxE, :) + data.AnticipatedE(data.InxE, :);
        anticipatedE = zeros(size(unanticipatedE));
        lastUnanticipatedE = max(data.LastUnanticipatedE, data.LastAnticipatedE);
        lastAnticipatedE = 0;
    end
    if isempty(anticipatedE) && isempty(unanticipatedE)
        ne = 0;
    end
end


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
    % inxZeroEffect = reshape(all(T==0, 1), [ ], 1);
    % inxReset = inxZeroEffect & ~isfinite(Xib_0);
else
    Xib_0 = reshape(data.ForceInit, [ ], 1);
    YXEPG(linxInit) = Xib_0;
end

% Required initial conditions already checked for NaNs; here reset any
% remaining (seeming) initial conditions
Xib_0(isnan(Xib_0)) = 0;


%===========================================================================
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
            lenVecAnticipatedE_t = numel(vecAnticipatedE_t);
            if lenR>lenVecAnticipatedE_t
                % Pad the the trailing missing anticipated shocks with
                % zeros to fit the size of the expanded R matrix
                lenToAdd = lenR - numel(vecAnticipatedE_t);
                vecAnticipatedE_t = [vecAnticipatedE_t; zeros(lenToAdd, 1)];
            elseif lenR<lenVecAnticipatedE_t
                % Cut off the anticipated shocks; this may happen in
                % backward looking models where no expansion is available
                vecAnticipatedE_t = vecAnticipatedE_t(1:lenR);
            end
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
%===========================================================================


if any(inxLog)
    YXEPG(inxLog, :) = exp(YXEPG(inxLog, :));
end

data.YXEPG = YXEPG;

end%

