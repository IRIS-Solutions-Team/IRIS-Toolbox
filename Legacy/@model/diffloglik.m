function [mll, grad, hess, varScale] = diffloglik(this, data, range, parameterNames, varargin)

persistent pp
%(
if isempty(pp)
    pp = extend.InputParser('@Model/diffloglik');
    pp.KeepUnmatched = true;
    addRequired(pp, 'inputData', @(x) validate.databank(x) || iscell(x));
    addRequired(pp, 'range', @validate.properRange);
    addRequired(pp, 'parameterNames', @(x) isstring(x) || ischar(x) || iscellstr(x));

    addParameter(pp, {'CheckSteady', 'ChkSstate'}, true, @model.validateChksstate);
    addParameter(pp, 'Progress', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Solve', true, @model.validateSolve);
    addParameter(pp, {'Steady', 'sstate', 'sstateopt'}, false, @model.validateSteady);
end
%)
opt = parse(pp, data, range, parameterNames, varargin{:});
unmatched = pp.UnmatchedInCell;

%
% Process Kalman filter options; `loglikopt` also expands solution forward
% if anticipated shifts in shocks are included
%
lik = prepareKalmanOptions(this, range, unmatched{:});


%
% Get measurement and exogenous variables including pre-sample
%
data = datarequest('yg*', this, data, range);


%
% Create StdCorr vector from user-supplied database:
% * clip=true means remove trailing NaNs
% * presample=true means include one presample period
%
optionsHere = struct('Clip', true, 'Presample', true);
lik.StdCorr = varyStdCorr(this, range, lik.Override, lik.Multiply, optionsHere);

%--------------------------------------------------------------------------

%
% Requested output data
%
lik.retpevec = true;
lik.retf = true;

if ischar(parameterNames)
    parameterNames = regexp(parameterNames, '\w+', 'match');
end
parameterNames = cellstr(parameterNames);

nv = countVariants(this);

%
% Multiple parameterizations are not allowed
%
if nv>1
    utils.error('model:diffloglik', ...
        'Cannot run diffloglik( ) on multiple parametrisations.');
end


%
% Find parameter names and create parameter index
%
ell = lookup(this.Quantity, parameterNames, 4);
posValues = ell.PosName;
posStdCorr = ell.PosStdCorr;
inxValidNames = ~isnan(posValues) | ~isnan(posStdCorr);
if any(~inxValidNames)
    utils.error('model:diffloglik', ...
        'This is not a valid parameter name: ''%s''.', ...
        parameterNames{~inxValidNames});
end


%
% Populate temporary Update container
%
this.Update = this.EMPTY_UPDATE;
this.Update.Values = this.Variant.Values;
this.Update.StdCorr = this.Variant.StdCorr;
this.Update.PosOfValues = posValues;
this.Update.PosOfStdCorr = posStdCorr;

if islogical(opt.Steady)
    opt.Steady ={"run", opt.Steady};
end
this.Update.Steady = prepareSteady(this, "silent", true, opt.Steady{:});

if islogical(opt.CheckSteady)
    opt.CheckSteady = {"run", opt.CheckSteady};
end
this.Update.CheckSteady = prepareCheckSteady(this, "silent", true, opt.CheckSteady{:});

if islogical(opt.Solve)
    opt.Solve = {"run", opt.Solve};
end
this.Update.Solve = prepareSolve(this, "silent", true, opt.Solve{:});

this.Update.NoSolution = 'Error';

%
% Call low-level diffloglik
%
[mll, grad, hess, varScale] = mydiffloglik(this, data, lik, opt);


%
% Clean up 
%
this.Update = this.EMPTY_UPDATE;

end%

