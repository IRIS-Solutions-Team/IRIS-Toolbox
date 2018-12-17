function swapped(this, data)

multipliers(this, data);
flat(this, data);
updateEndogenizedE(this, data);
retrieveE(data);
flat(this, data);

end%


%
% Local Functions
%


function updateEndogenizedE(this, data)
% Evaluate discrepancy between the exogenized values and their targets,
% and calculate the implied increments to the endogenized shocks
    discrepancy = evaluateDiscrepancy(data);
    addE = this.FirstOrderMultipliers \ discrepancy(:);
    data.YXEPG(data.Endogenized) = data.YXEPG(data.Endogenized) + addE;
end%


function discrepancy = evaluateDiscrepancy(data)
% Evaluate discrepancy between the exogenized values and their targets
    exogenized = data.Exogenized;
    target = data.Target(exogenized);
    YXEPG = data.YXEPG(exogenized);
    if any(data.InxOfLog)
        % Take care of log-variables if there are any
        inxOfLog = repmat(data.InxOfLog, 1, data.NumOfExtendedPeriods);
        inxOfLogExogenized = inxOfLog(exogenized);
        target(inxOfLogExogenized) = log(target(inxOfLogExogenized));
        YXEPG(inxOfLogExogenized) = log(YXEPG(inxOfLogExogenized));
    end
    discrepancy = target - YXEPG;
end%

