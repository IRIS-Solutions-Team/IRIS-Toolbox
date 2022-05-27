function swapped(this, data)

% This simulation modifies shocks and they need to be updated in the output
% databank
data.NeedsUpdateShocks = true;

calculateShockMultipliers(this, data);
flat(this, data);
local_updateEndogenizedE(this, data);
flat(this, data);

end%

%
% Local Functions
%

function local_updateEndogenizedE(this, data)
% Evaluate discrepancy between the inxExogenized values and their targets,
% and calculate the implied increments to the endogenized shocks
    inxEndogenizedE = data.InxEndogenizedE;
    inxAnticipatedE = data.InxAnticipatedE;
    inxUnanticipatedE = data.InxUnanticipatedE;
    discrepancy = local_evaluateDiscrepancy(data);
    if ~isempty(this.KalmanGain)
        vecAddToE = this.KalmanGain * discrepancy(:);
    else
        [numExogenized, numEndogenized] = size(this.FirstOrderMultipliers);
        if numExogenized==numEndogenized && ~strcmpi(this.PlanMethod, 'Condition')
            vecAddToE = this.FirstOrderMultipliers \ discrepancy(:);
        else
            F = this.FirstOrderMultipliers * data.Sigma * transpose(this.FirstOrderMultipliers);
            vecAddToE = data.Sigma * transpose(this.FirstOrderMultipliers) * (F\discrepancy(:));
        end
    end

    addToE = data.EmptySparse; 
    addToE(inxEndogenizedE) = vecAddToE;
    data.AnticipatedE(inxAnticipatedE, :) ...
        = data.AnticipatedE(inxAnticipatedE, :) + addToE(inxAnticipatedE, :);
    data.UnanticipatedE(inxUnanticipatedE, :) ...
        = data.UnanticipatedE(inxUnanticipatedE, :) + addToE(inxUnanticipatedE, :);
end%


function discrepancy = local_evaluateDiscrepancy(data)
% Evaluate discrepancy between the inxExogenized values and their targets
    inxExogenizedYX = data.InxExogenizedYX;
    target = data.TargetYX(inxExogenizedYX);
    actual = data.YXEPG(inxExogenizedYX);
    if any(data.InxLog)
        % Take care of log-variables if there are any
        inxLogWithinYXEPG = repmat(data.InxLog, 1, data.NumColumns);
        inxLogWithinExogenizedYX = inxLogWithinYXEPG(inxExogenizedYX);
        target(inxLogWithinExogenizedYX) = log(target(inxLogWithinExogenizedYX));
        actual(inxLogWithinExogenizedYX) = log(actual(inxLogWithinExogenizedYX));
    end
    discrepancy = target - actual;
end%

