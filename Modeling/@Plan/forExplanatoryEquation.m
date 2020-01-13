function this = forExplanatoryEquation(xq, simulationRange)
% forExplanatoryEquation  Construct a simulation Plan object for ExplanatoryEquation object or array
%{
% ## Syntax ##
%
%
%     p = Plan.forExplanatoryEquation(xq, simulationRange, ...)
%
%
% ## Input Arguments ##
%
%
% __`xq`__ [ ExplanatoryEquation ]
% >
% ExplanatoryEquation object or array for which the new simulation Plan `p`
% will be created on the `simulationRange`.
%
%
% __`simulationRange`__ [ DateWrapper ]
% >
% Range on which the `xq` will be simulated using the plan `p`.
%
%
% ## Output Arguments ##
%
%
% __`p`__ [ Plan ]
% >
% A new simulation Plan object that can be use when simulating the `xq`
% object or array on the `simulationRange`.
%
%
% ## Description ##
%
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('Plan.Plan');
    parser.addRequired('xq', @(x) isa(x, 'ExplanatoryEquation'));
    parser.addRequired('simulationRange', @DateWrapper.validateProperRangeInput);
end
parser.parse(xq, simulationRange);
simulationRange = double(simulationRange);

%--------------------------------------------------------------------------

this = Plan( );
this.BaseStart = simulationRange(1);
this.BaseEnd = simulationRange(end);
this = preparePlan(xq, this);

numEndogenous = this.NumOfEndogenous;
numExogenous = this.NumOfExogenous;
numExtendedPeriods = this.NumOfExtendedPeriods;
this.IdOfAnticipatedExogenized = zeros(numEndogenous, numExtendedPeriods, 'int16');
this.IdOfUnanticipatedExogenized = zeros(numEndogenous, numExtendedPeriods, 'int16');
this.IdOfAnticipatedEndogenized = zeros(numExogenous, numExtendedPeriods, 'int16');
this.IdOfUnanticipatedEndogenized = zeros(numExogenous, numExtendedPeriods, 'int16');
this.InxToKeepEndogenousNaN = false(numEndogenous, numExtendedPeriods);

this.AnticipationStatusOfEndogenous = repmat(this.DefaultAnticipationStatus, numEndogenous, 1);
this.AnticipationStatusOfExogenous = repmat(this.DefaultAnticipationStatus, numExogenous, 1);

this.AllowUnderdetermined = true;
this.AllowOverdetermined = true;

end%

