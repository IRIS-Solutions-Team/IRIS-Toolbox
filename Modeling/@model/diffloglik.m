function [minusLogLik, grad, hess, v] ...
    = diffloglik(this, data, range, parameterNames, varargin)
% diffloglik  Approximate gradient and hessian of log-likelihood function
%
% __Syntax__
%
%     [MinusLogLik, Grad, Hess, V] = diffloglik(M, Inp, Range, PList, ...)
%
%
% __Input arguments__
%
% * `M` [ model ] - Model object whose likelihood function will be
% differentiated.
%
% * `Inp` [ cell | struct ] - Input data from which measurement variables
% will be taken.
%
% * `Range` [ numeric | char ] - Date range on which the likelihood
% function will be evaluated.
%
% * `PList` [ cellstr ] - List of model parameters with respect to which
% the likelihood function will be differentiated.
%
%
% __Output arguments__
%
% * `MinusLogLik` [ numeric ] - Value of minus the likelihood function at the input
% data.
%
% * `Grad` [ numeric ] - Gradient (or score) vector.
%
% * `Hess` [ numeric ] - Hessian (or information) matrix.
%
% * `V` [ numeric ] - Estimated variance scale factor if the `'relative='`
% options is true; otherwise `v` is 1.
%
%
% __Options__
%
% * `'ChkSstate='` [ `true` | *`false`* | cell ] - Check steady state in
% each iteration; works only in non-linear models.
%
% * `'Solve='` [ *`true`* | `false` | cellstr ] - Re-compute solution for
% each parameter change; you can specify a cell array with options for the
% `solve` function.
%
% * `'Sstate='` [ `true` | *`false`* | cell ] - Re-compute steady state in each
% differentiation step; if the model is non-linear, you can pass in a cell
% array with options used in the `sstate( )` function.
%
% See help on [`model/filter`](model/filter) for other options available.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

pp = inputParser( );
pp.addRequired('Inp', @(x) isstruct(x) || iscell(x));
pp.addRequired('Range', @DateWrapper.validateDateInput);
pp.addRequired('PList', @(x) ischar(x) || iscellstr(x));
pp.parse(data, range, parameterNames);

[opt, varargin] = passvalopt('model.diffloglik', varargin{:});

% Process Kalman filter options; `loglikopt` also expands solution forward
% if needed for tunes on the mean of shocks.
if ischar(range)
    range = textinp2dat(range);
end
lik = prepareLoglik(this, range, 't', [ ], varargin{:});

% Get measurement and exogenous variables including pre-sample.
data = datarequest('yg*', this, data, range);

% Create StdCorr vector from user-supplied database:
% * --clip means remove trailing NaNs
% * --presample means include one presample period
lik.StdCorr = varyStdCorr(this, range, [ ], lik, '--clip', '--presample');

% Requested output data.
lik.retpevec = true;
lik.retf = true;

if ischar(parameterNames)
    parameterNames = regexp(parameterNames, '\w+', 'match');
end

%--------------------------------------------------------------------------

nv = length(this);

% Multiple parameterizations are not allowed.
if nv>1
    utils.error('model:diffloglik', ...
        'Cannot run diffloglik( ) on multiple parametrisations.');
end

% Find parameter names and create parameter index.
ell = lookup(this.Quantity, parameterNames, TYPE(4));
posValues = ell.PosName;
posStdCorr = ell.PosStdCorr;
indexValidNames = ~isnan(posValues) | ~isnan(posStdCorr);
if any(~indexValidNames)
    utils.error('model:diffloglik', ...
        'This is not a valid parameter name: ''%s''.', ...
        parameterNames{~indexValidNames});
end

% Populate temporary Update container
this.Update = this.EMPTY_UPDATE;
this.Update.Values = this.Variant.Values;
this.Update.StdCorr = this.Variant.StdCorr;
this.Update.PosOfValues = posValues;
this.Update.PosOfStdCorr = posStdCorr;
this.Update.Steady = prepareSteady(this, 'silent', opt.Steady);
this.Update.CheckSteady = prepareChkSteady(this, 'silent', opt.ChkSstate);
this.Update.Solve = prepareSolve(this, 'silent, fast', opt.Solve);
this.Update.ThrowError = true;

% Call low-level diffloglik.
[minusLogLik, grad, hess, v] = mydiffloglik(this, data, lik, opt);

% Clean up even though the model objects is not returned
this.Update = this.EMPTY_UPDATE;

end
