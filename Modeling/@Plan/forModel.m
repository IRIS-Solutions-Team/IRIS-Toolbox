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

persistent parser
if isempty(parser)
    parser = extend.InputParser('Plan.Plan');
    parser.addRequired('model', @(x) isa(x, 'shared.Plan'));
    parser.addRequired('simulationRange', @DateWrapper.validateProperRangeInput);
    parser.addParameter({'DefaultAnticipationStatus', 'DefaultAnticipate', 'Anticipate'}, true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Method', 'Exogenize', @(x) isequal(x, @auto) || validate.anyString(x, 'Exogenize', 'Condition'));
end
parser.parse(varargin{:});
opt = parser.Options;
simulationRange = double(parser.Results.simulationRange);
model = parser.Results.model;

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

this.AnticipationStatusOfEndogenous = repmat(this.DefaultAnticipationStatus, numEndogenous, 1);
this.AnticipationStatusOfExogenous = repmat(this.DefaultAnticipationStatus, numExogenous, 1);

this.Method = opt.Method;
if strcmpi(this.Method, 'Exogenize')
    this.AllowUnderdetermined = false;
else
    this.AllowUnderdetermined = true;
end

end%

