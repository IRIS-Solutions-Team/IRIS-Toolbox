% anticipate  Set anticipation status individually 

function this = anticipate(this, anticipationStatus, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('@Plan/anticipate');
    addRequired(pp, 'plan', @(x) isa(x, 'Plan'));
    addRequired(pp, 'anticipationStatus', @validate.logicalScalar);
    addRequired(pp, 'names', @(x) validate.list(x) || (iscell(x) && isscalar(x) && validate.list(x{1})));
end
%)

if this.NumOfEndogenizedPoints>0 || this.NumOfExogenizedPoints>0
    exception.error([
        "Plan:CannotChangeAnticipateAfterEndogenize"
        "Cannot change anticipation status in a Plan object "
        "after some names have been already exogenized or endogenized"
    ]);
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
    this.AnticipationStatusEndogenous(inxEndogenous) = anticipationStatus;
end

inxExogenous = this.resolveNames(names, this.NamesOfExogenous, context, throwError);
if any(inxExogenous)
    this.AnticipationStatusExogenous(inxExogenous) = anticipationStatus;
end

end%

