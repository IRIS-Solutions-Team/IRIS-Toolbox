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
        vecAddToE = this.InvFirstOrderMultipliers * discrepancy(:);
    else
        vecAddToE = this.FirstOrderMultipliers \ discrepancy(:);
    end
    addToE = zeros(data.NumOfE, data.NumOfExtendedPeriods);
    addToE(inxOfEndogenizedE) = addToE(inxOfEndogenizedE) + vecAddToE;
    inx = data.AnticipationStatusOfE;
    data.AnticipatedE(inx, :) = data.AnticipatedE(inx, :) ...
                              + addToE(inx, :);
    data.UnanticipatedE(~inx, :) = data.UnanticipatedE(~inx, :) ...
                                   + addToE(~inx, :);
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

