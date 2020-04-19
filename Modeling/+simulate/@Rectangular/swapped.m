function swapped(this, data)

% This simulation modifies shocks and they need to be updated in the output
% databank
data.NeedsUpdateShocks = true;

calculateShockMultipliers(this, data);
flat(this, data);
updateEndogenizedE(this, data);
flat(this, data);

end%


%
% Local Functions
%


function updateEndogenizedE(this, data)
% Evaluate discrepancy between the inxExogenized values and their targets,
% and calculate the implied increments to the endogenized shocks
    inxEndogenizedE = data.InxOfEndogenizedE;
    discrepancy = evaluateDiscrepancy(data);
    if ~isempty(this.KalmanGain)
        vecAddToE = this.KalmanGain * discrepancy(:);
    else
        [numExogenized, numEndogenized] = size(this.FirstOrderMultipliers);
        if numExogenized==numEndogenized && ~strcmpi(this.PlanMethod, 'Condition')
            vecAddToE = this.FirstOrderMultipliers \ discrepancy(:);
        else
            F = this.FirstOrderMultipliers*data.Sigma*this.FirstOrderMultipliers';
            vecAddToE = data.Sigma*this.FirstOrderMultipliers'*(F\discrepancy(:));
        end
    end
    addToE = zeros(data.NumOfE, data.NumOfColumns);
    addToE(inxEndogenizedE) = addToE(inxEndogenizedE) + vecAddToE;
    inx = data.AnticipationStatusOfE;
    data.AnticipatedE(inx, :) ...
        = data.AnticipatedE(inx, :) + addToE(inx, :);
    data.UnanticipatedE(~inx, :) ...
        = data.UnanticipatedE(~inx, :) + addToE(~inx, :);
end%




function discrepancy = evaluateDiscrepancy(data)
% Evaluate discrepancy between the inxExogenized values and their targets
    inxExogenizedYX = data.InxOfExogenizedYX;
    target = data.Target(inxExogenizedYX);
    actual = data.YXEPG(data.InxOfYX, :);
    actual = actual(inxExogenizedYX);
    if any(data.InxLog)
        % Take care of log-variables if there are any
        inxLogYX = repmat(data.InxLog(data.InxOfYX), 1, data.NumOfColumns);
        inxLogExogenizedYX = inxLogYX(inxExogenizedYX);
        target(inxLogExogenizedYX) = log(target(inxLogExogenizedYX));
        actual(inxLogExogenizedYX) = log(actual(inxLogExogenizedYX));
    end
    discrepancy = target - actual;
end%

