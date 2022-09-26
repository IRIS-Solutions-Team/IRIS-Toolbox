%{
% 
% # `diffloglik` ^^(Model)^^
% 
% {== Approximate gradient and hessian of log-likelihood function ==}
% 
% 
% ## Syntax 
% 
%     [mll, Grad, Hess, varScale] = diffloglik(M, Inp, Range, PList, ...)
% 
% 
% ## Input arguments 
% 
%     `M` [ model ]
% > 
% > Model object whose likelihood function will be differentiated
% > 
% 
%     `Inp` [ cell | struct ]
% > 
% > Input data from which measurement variables will be taken.
% > 
% 
%     `Range` [ numeric | char ]
% > 
% > Date range on which the likelihood function will be evaluated.
% > 
% 
%     `PList` [ cellstr ]
% > 
% > List of model parameters with respect to which
% > the likelihood function will be differentiated.
% > 
% 
% ## Output arguments 
% 
% 
%     `mll` [ numeric ]
% > 
% > Value of minus the likelihood function at the input data.
% > 
% 
%     `Grad` [ numeric ]
% > 
% > Gradient (or score) vector.
% > 
% 
%     `Hess` [ numeric ]
% > 
% > Hessian (or information) matrix.
% > 
% 
%     `varScale` [ numeric ]
% > 
% > Estimated variance scale factor if the `'relative='`
% > options is true; otherwise `v` is 1.
% > 
% 
% ## Options 
% 
%     `'CheckSteady='` [ `true` | *`false`* | cell ]
% > 
% > Check steady state in each iteration; works only in non-linear models.
% > 
% 
%     `'Solve='` [ *`true`* | `false` | cellstr ]
% > 
% > Re-compute solution for each parameter change; you can specify 
% > a cell array with options for the `solve` function.
% > 
% 
%     `'Sstate='` [ `true` | *`false`* | cell ]
% > 
% > Re-compute steady state in each differentiation step; if the model 
% > is non-linear, you can pass in a cell array with options used 
% > in the `sstate( )` function.
% > 
% 
% > See help on [`model/filter`](model/filter) for other options available.
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
% 
%}
% --8<--


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

