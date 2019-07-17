function this = anticipate(this, anticipationStatus, names)
% anticipate  Set anticipation status for individual shocks
%
% __Syntax__
%
%     plan = anticipate(plan, anticipationStatus, names)
%
%
% __Input Arguments__
%
% * `plan` [ Plan ] - Simulation plan.
%
% * `anticipationStatus` [ true | false ] - New anticipation status for the
% shocks listed in `names`.
%
% * `names` [ char | string | cellstr ] - List of shocks whose anticipation
% status will be set to `anticipationStatus`.
%
%
% __Output Arguments__
%
% * p [ Plan ] - Simulation plan with a new anticipation status for the
% specified shocks.
%
%
% __Description__
%
%
% __Example__
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team


persistent parser
if isempty(parser)
    parser = extend.InputParser('@Plan/anticipate');
    addRequired(parser, 'Plan', @(x) isa(x, 'Plan'));
    addRequired(parser, 'AnticipationStatus', @Valid.logicalScalar);
    addRequired(parser, 'NamesOfExogenous', @Valid.list);
end

if this.NumOfEndogenizedPoints>0
    THIS_ERROR = { 'Plan:CannotChangeAnticipateAfterEndogenize'
                   'Cannot change anticipation status after some names have been already endogenized' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

try
    parse(parser, this, anticipationStatus, names);
catch
    [names, anticipationStatus] = deal(anticipationStatus, names);
    parse(parser, this, anticipationStatus, names);
    THIS_WARNING = { 'Plan:AnticipateLegacyInputArgumentsForGPMN' 
                     'Invalid order of input arguments to @Plan/anticipate; this will become an error in a future release of IRIS. See help Plan/anticipate.' };
    throw( exception.Base(THIS_WARNING, 'warning') );
end

%--------------------------------------------------------------------------

context = 'be assigned anticipation status';
this.resolveNames(names, this.AllNames, context);
throwError = false;
inxOfEndogenous = this.resolveNames(names, this.NamesOfEndogenous, context, throwError);
if any(inxOfEndogenous)
    this.AnticipationStatusOfEndogenous(inxOfEndogenous) = anticipationStatus;
end
inxOfExogenous = this.resolveNames(names, this.NamesOfExogenous, context, throwError);
if any(inxOfExogenous)
    this.AnticipationStatusOfExogenous(inxOfExogenous) = anticipationStatus;
end

end%

