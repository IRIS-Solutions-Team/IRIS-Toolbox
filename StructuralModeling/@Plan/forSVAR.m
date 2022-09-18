
function this = forExplanatory(svar, simulationRange)

%( Input parser
persistent ip
if isempty(ip)
    ip = extend.InputParser('Plan.Plan');
    addRequired(ip, 'svar', @(x) isa(x, 'SVAR'));
    addRequired(ip, 'simulationRange', @validate.properRange);
end
parse(ip, svar, simulationRange);
simulationRange = double(simulationRange);
%)


this = Plan();
this.BaseStart = simulationRange(1);
this.BaseEnd = simulationRange(end);
this = preparePlan(svar, this);

numEndogenous = this.NumOfEndogenous;
numExogenous = this.NumOfExogenous;
numExtendedPeriods = this.NumExtdPeriods;
this.IdAnticipatedExogenized = zeros(numEndogenous, numExtendedPeriods, 'int16');
this.IdUnanticipatedExogenized = zeros(numEndogenous, numExtendedPeriods, 'int16');
this.IdAnticipatedEndogenized = zeros(numExogenous, numExtendedPeriods, 'int16');
this.IdUnanticipatedEndogenized = zeros(numExogenous, numExtendedPeriods, 'int16');
this.InxToKeepEndogenousNaN = false(numEndogenous, numExtendedPeriods);

this.AnticipationStatusEndogenous = repmat(this.DefaultAnticipationStatus, numEndogenous, 1);
this.AnticipationStatusExogenous = repmat(this.DefaultAnticipationStatus, numExogenous, 1);

this.AllowUnderdetermined = true;
this.AllowOverdetermined = true;

end%

