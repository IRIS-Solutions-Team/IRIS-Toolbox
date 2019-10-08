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
% -Copyright (c) 2007-2019 IRIS Solutions Team


persistent parser
if isempty(parser)
    parser = extend.InputParser('@Plan/anticipate');
    addRequired(parser, 'plan', @(x) isa(x, 'Plan'));
    addRequired(parser, 'anticipationStatus', @validate.logicalScalar);
    addRequired(parser, 'names', @(x) validate.list(x) || (iscell(x) && isscalar(x) && validate.list(x{1})));
end

if this.NumOfEndogenizedPoints>0
    thisError = { 'Plan:CannotChangeAnticipateAfterEndogenize'
                  'Cannot change anticipation status after some names have been already endogenized' };
    throw(exception.Base(thisError, 'error'));
end

names = varargin;
try
    parse(parser, this, anticipationStatus, names);
catch
    % TODO: Legacy input arguments
    [names, anticipationStatus] = deal(anticipationStatus, names{1});
    parse(parser, this, anticipationStatus, names);
    thisWarning = { 'Plan:AnticipateLegacyInputArgumentsForGPMN' 
                    'Invalid order of input arguments to @Plan/anticipate; this will become an error in a future release of IRIS. See help Plan/anticipate.' };
    throw(exception.Base(thisWarning, 'warning'));
end

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

