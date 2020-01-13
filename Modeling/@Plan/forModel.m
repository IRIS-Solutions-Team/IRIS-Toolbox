function this = forModel(varargin)
% forModel  Construct a simulation Plan object for a Model
%{
% ## Syntax ##
%
%
%     p = Plan.forModel(model, simulationRange, ...)
%
%
% ## Input Arguments ##
%
%
% __`model`__ [ Model ]
% >
% Model object for which the new simulation Plan `p` will be created on the
% `simulationRange`.
%
%
% __`simulationRange`__ [ DateWrapper ]
% >
% Range on which the `model` will be simulated using the plan `p`.
%
%
% ## Output Arguments ##
%
%
% __`p`__ [ Plan ]
% >
% A new simulation Plan object that can be use when simulating the `model`
% on the `simulationRange`.
%
%
% ## Options ##
%
%
% __`DefaultAnticipationStatus=true`__ [ `true` | `false` ]
% >
% The default anticipation status for exogenized and endogenized
% quantities.
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

persistent pp
if isempty(pp)
    pp = extend.InputParser('Plan.Plan');
    addRequired(pp, 'model', @(x) isa(x, 'Model'));
    addRequired(pp, 'simulationRange', @DateWrapper.validateProperRangeInput);
    addParameter(pp, {'DefaultAnticipationStatus', 'DefaultAnticipate', 'Anticipate'}, true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Method', 'Exogenize', @(x) isequal(x, @auto) || validate.anyString(x, 'Exogenize', 'Condition'));
end
pp.parse(varargin{:});
opt = pp.Options;
simulationRange = double(pp.Results.simulationRange);
model = pp.Results.model;

%--------------------------------------------------------------------------

this = Plan( );
this.BaseStart = simulationRange(1);
this.BaseEnd = simulationRange(end);
this = preparePlan(model, this);

this.DefaultAnticipationStatus = opt.DefaultAnticipationStatus;

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

this.Method = opt.Method;
if strcmpi(this.Method, 'Exogenize')
    this.AllowUnderdetermined = false;
else
    this.AllowUnderdetermined = true;
end

end%

