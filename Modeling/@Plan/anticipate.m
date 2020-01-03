function this = anticipate(this, anticipationStatus, varargin)
% anticipate  Set anticipation status individually 
%{
% ## Syntax ##
%
%     plan = anticipate(plan, anticipationStatus, names)
%     plan = anticipate(plan, anticipationStatus, name, name, etc...)
%
%
% ## Input Arguments ##
%
% __`plan`__ [ Plan ] - 
% Simulation plan.
%
% __`anticipationStatus`__ [ true | false ] -
% New anticipation status for the quantities listed in `names`.
%
% __`names`__ [ char | string | cellstr ] -
% List of quantities whose anticipation status will be set to
% `anticipationStatus`.
%
% __`name`__ [ char | string ] -
% Name of quantity whose anticipation status will be set to
% `anticipationStatus`.
%
%
% ## Output Arguments ##
%
% * p [ Plan ] -
% Simulation plan with a new anticipation status for the specified
% quantities.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team


persistent pp
if isempty(pp)
    pp = extend.InputParser('@Plan/anticipate');
    addRequired(pp, 'plan', @(x) isa(x, 'Plan'));
    addRequired(pp, 'anticipationStatus', @validate.logicalScalar);
    addRequired(pp, 'names', @(x) validate.list(x) || (iscell(x) && isscalar(x) && validate.list(x{1})));
end

if this.NumOfEndogenizedPoints>0 || this.NumOfExogenizedPoints>0
    thisError = [ "Plan:CannotChangeAnticipateAfterEndogenize"
                  "Cannot change anticipation status in a Plan object "
                  "after some names have been already exogenized or endogenized" ];
    throw(exception.Base(thisError, 'error'));
end

names = varargin;
parse(pp, this, anticipationStatus, names);

if ~validate.list(names)
    names = names{1};
end

%--------------------------------------------------------------------------

context = 'be assigned anticipation status';
throwError = false;

this.resolveNames(names, this.AllNames, context);

inxEndogenous = this.resolveNames(names, this.NamesOfEndogenous, context, throwError);
if any(inxEndogenous)
    this.AnticipationStatusOfEndogenous(inxEndogenous) = anticipationStatus;
end

inxExogenous = this.resolveNames(names, this.NamesOfExogenous, context, throwError);
if any(inxExogenous)
    this.AnticipationStatusOfExogenous(inxExogenous) = anticipationStatus;
end

end%

