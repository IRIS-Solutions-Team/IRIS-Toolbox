function [minusLogLik, grad, hess, v] ...
    = diffloglik(this, data, range, listOfParameters, varargin)
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

pp = inputParser( );
pp.addRequired('Inp', @(x) isstruct(x) || iscell(x));
pp.addRequired('Range', @DateWrapper.validateDateInput);
pp.addRequired('PList', @(x) ischar(x) || iscellstr(x));
pp.parse(data, range, listOfParameters);

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

if ischar(listOfParameters)
    listOfParameters = regexp(listOfParameters, '\w+', 'match');
end

%--------------------------------------------------------------------------

nAlt = length(this);

% Multiple parameterizations are not allowed.
if nAlt>1
    utils.error('model:diffloglik', ...
        'Cannot run diffloglik( ) on multiple parametrisations.');
end

% Find parameter names and create parameter index.
ell = lookup(this.Quantity, listOfParameters, TYPE(4));
posQty = ell.PosName;
posStdCorr = ell.PosStdCorr;
ixValid = ~isnan(posQty) | ~isnan(posStdCorr);
if any(~ixValid)
    utils.error('model:diffloglik', ...
        'This is not a valid parameter name: ''%s''.', ...
        listOfParameters{~ixValid});
end

pri = model.component.IterateOver( );
pri.PosQty = posQty;
pri.PosStdCorr = posStdCorr;
pri.Quantity = this.Variant.Values;
pri.StdCorr = this.Variant.StdCorr;

% Call low-level diffloglik.
[minusLogLik, grad, hess, v] = mydiffloglik(this, data, pri, lik, opt);

end
