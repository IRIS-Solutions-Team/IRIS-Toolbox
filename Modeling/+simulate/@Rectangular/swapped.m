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
    inxOfEndogenized = data.InxOfEndogenized;
    discrepancy = evaluateDiscrepancy(data);
    addE = this.FirstOrderMultipliers \ discrepancy(:);
    temp = data.YXEPG(inxOfEndogenized);
    tempImag = imag(temp);
    tempReal = real(temp);
    tempReal = tempReal + addE;
    if nnz(tempImag~=0)
        data.YXEPG(inxOfEndogenized) = complex(tempReal, tempImag);
    else
        data.YXEPG(inxOfEndogenized) = tempReal;
    end
    updateE(data);
end%


function discrepancy = evaluateDiscrepancy(data)
% Evaluate discrepancy between the inxOfExogenized values and their targets
    inxOfExogenized = data.InxOfExogenized;
    target = data.Target(inxOfExogenized);
    YXEPG = data.YXEPG(inxOfExogenized);
    if any(data.InxOfLog)
        % Take care of log-variables if there are any
        inxOfLog = repmat(data.InxOfLog, 1, data.NumOfExtendedPeriods);
        inxOfLogExogenized = inxOfLog(inxOfExogenized);
        target(inxOfLogExogenized) = log(target(inxOfLogExogenized));
        YXEPG(inxOfLogExogenized) = log(YXEPG(inxOfLogExogenized));
    end
    discrepancy = target - YXEPG;
end%

