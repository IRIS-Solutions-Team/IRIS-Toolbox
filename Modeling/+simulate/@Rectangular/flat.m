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
lastUnanticipatedE = 0;
if isempty(anticipatedE) && isempty(unanticipatedE)
    ne = 0;
elseif ne>0
    if data.MixinUnanticipated
        lastUnanticipatedE = data.LastUnanticipatedE;
    else
        lastUnanticipatedE = firstColumn;
    end
    lastAnticipatedE = data.LastAnticipatedE;
end

% Retrieve first-order solution after making sure expansion is sufficient
[T, R, K, Z, H, D, Q] = this.FirstOrderSolution{:};
R0 = R(:, 1:ne);
lenOfR = size(R, 2);

% Nonlinear add-factors
nlaf = data.NonlinAddf;
lastNlaf = 0;
nlafExist = ~isempty(Q) && ~isempty(nlaf) && any(nlaf(:)~=0);
if nlafExist
    lastNlaf = find(any(nlaf~=0, 1), 1, 'last');
    if isempty(lastNlaf)
        lastNlaf = 0;
    end
    Q = Q(:, 1:(lastNlaf-firstColumn+1)*nh);
    lenOfQ = size(Q, 2);
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
        if t<=lastUnanticipatedE
            Xi_t = Xi_t + R0*unanticipatedE(:, t);
        end
        if t<=lastAnticipatedE
            vecAnticipatedE_t = anticipatedE(:, t:lastAnticipatedE);
            vecAnticipatedE_t = vecAnticipatedE_t(:);
            lenToAdd = lenOfR - numel(vecAnticipatedE_t);
            vecAnticipatedE_t = [vecAnticipatedE_t; zeros(lenToAdd, 1)];
            Xi_t = Xi_t + R*vecAnticipatedE_t;
        end
    end

    if t<=lastNlaf
        % Add nonlinear add-factors
        nlaf_t = nlaf(:, t:lastNlaf);
        nlaf_t = nlaf_t(:);
        lenToAdd = lenOfQ - numel(nlaf_t);
        nlaf_t = [nlaf_t; zeros(lenToAdd, 1)];
        Xi_t = Xi_t + Q*nlaf_t;
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
            E_t = anticipatedE(:, t);
            if t<=lastUnanticipatedE
                E_t = E_t + unanticipatedE(:, t);
            end
            Y_t = Y_t + H*E_t;
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

