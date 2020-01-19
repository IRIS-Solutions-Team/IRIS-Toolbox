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
% The `Plan` object created by `Plan.forExplanatoryEquation( )` is to be
% used in an `ExplanatoryEquation/simulate( )` function to specify the
% exogenized variables. Only the LHS variables in non-identities can be
% exogenized.  When an LHS variables is exogenized, the respective residual
% belonging to the equation is endogenized in the same periods; this is
% done automatically and no `endogenize( )` or `swap( )` functions are
% called by the user.
% 
% There are two ways how to exogenize a variable in a `Plan` created for an
% `Explanatory: 
%
% * `exogenize( )` exogenizes some LHS variables in some periods no matter
% what;
%
% * `exogenizeWhenData( )` exogenizes some LHS variables in specified
% periods; however, if data are missing (i.e. are `NaN`) for a particular
% exogenized point, the variabe in that period is not exogenized
% and treated endogenously instead.
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

