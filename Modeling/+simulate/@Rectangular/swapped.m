function swapped(this, data)

multipliers(this, data);
flat(this, data);
updateEndogenizedE(this, data);
flat(this, data);

end%


%
% Local Functions
%


function updateEndogenizedE(this, data)
% Evaluate discrepancy between the inxOfExogenized values and their targets,
% and calculate the implied increments to the endogenized shocks
    inxOfEndogenizedE = data.InxOfEndogenizedE;
    discrepancy = evaluateDiscrepancy(data);
    if ~isempty(this.InvFirstOrderMultipliers)
        addToE = this.InvFirstOrderMultipliers * discrepancy(:);
    else
        addToE = this.FirstOrderMultipliers \ discrepancy(:);
    end
    E = data.YXEPG(data.InxOfE, :);
    temp = E(inxOfEndogenizedE);
    tempImag = imag(temp);
    tempReal = real(temp);
    tempReal = tempReal + addToE;
    if nnz(tempImag~=0)
        E(inxOfEndogenizedE) = complex(tempReal, tempImag);
    else
        E(inxOfEndogenizedE) = tempReal;
    end
    data.YXEPG(data.InxOfE, :) = E;
    updateE(data);
end%


function discrepancy = evaluateDiscrepancy(data)
% Evaluate discrepancy between the inxOfExogenized values and their targets
    inxOfExogenizedYX = data.InxOfExogenizedYX;
    target = data.Target(inxOfExogenizedYX);
    actual = data.YXEPG(data.InxOfYX, :);
    actual = actual(inxOfExogenizedYX);
    if any(data.InxOfLog)
        % Take care of log-variables if there are any
        inxOfLogYX = repmat(data.InxOfLog(data.InxOfYX), 1, data.NumOfExtendedPeriods);
        inxOfLogExogenizedYX = inxOfLogYX(inxOfExogenizedYX);
        target(inxOfLogExogenizedYX) = log(target(inxOfLogExogenizedYX));
        actual(inxOfLogExogenizedYX) = log(actual(inxOfLogExogenizedYX));
    end
    discrepancy = target - actual;
end%

