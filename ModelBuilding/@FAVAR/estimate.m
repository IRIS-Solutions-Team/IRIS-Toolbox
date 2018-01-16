function [this, D, CC, FF, U, E, CTF, range] = estimate(this, d, range, varargin)
% estimate  Estimate FAVAR using static principal components.
%
% Syntax
% =======
%
%     [A, D, CC, F, U, E, CTF] = estimate(A, D, Range, [R, Q], ...)
%
%
% Input arguments
% ================
%
% * `A` [ FAVAR ] - Empty FAVAR object.
%
% * `D` [ struct ] - Input database.
%
% * `Range` [ numeric ] - Estimation range.
%
% * `R` [ numeric ] - Selection criterion for the number of factors:
% Minimum requested proportion of input data volatility explained by the
% factors.
%
% * `Q` [ numeric ] - Selection criterion for the number of factors:
% Maximum number of factors.
%
%
% Output arguments
% =================
%
% * `A` [ FAVAR ] - Estimated FAVAR object.
%
% * `D` [ struct ] - Output database.
%
% * `CC` [ tseries ] - Estimates of common components in the FAVAR
% observables.
%
% * `F` [ tseries ] - Estimates of factors.
%
% * `U` [ struct | tseries ] - Idiosyncratic residuals.
%
% * `E` [ tseries ] - Factor VAR residuals.
%
% * `CTF` [ tseries ] - Contributions of individual input series to the
% estimated factors.
%
%
% Options
% ========
%
% * `'Cross='` [ *`true`* | `false` | numeric ] - Keep off-diagonal
% elements in the covariance matrix of idiosyncratic residuals; if false
% all cross-covariances are reset to zero; if a number between zero and
% one, all cross-covariances are multiplied by that number.
%
% * `'Order='` [ numeric | *1* ] - Order of the VAR for factors.
%
% * `'Rank='` [ numeric | *`Inf`* ] - Restriction on the rank of the factor
% VAR residuals.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );

% Get input data.
[y, range, lsy] = getEstimationData(this, d, range);

if isempty(this.NamesEndogenous) && isequal(inpFmt, 'dbase')
    % ##### Nov 2013 OBSOLETE and scheduled for removal.
    this.NamesEndogenous = lsy;
end

this.Range = range;

% Parse required input arguments.
crit = varargin{1};
varargin(1) = [ ];

% Parse and validate options.
opt = passvalopt('FAVAR.estimate', varargin{:});

%--------------------------------------------------------------------------

% Standardise input data.
y0 = y;
[this, y] = standardise(this, y);

% Estimate static factors using principal components.
[FF, this.C, U, this.Sigma, this.SingVal, sample, CTF] = ...
    FAVAR.pc(y, crit, opt.method);

% Estimate VAR(p, q) on factors.
[this.A, this.B, this.Omega, E, this.IxFitted] = ...
    FAVAR.estimatevar(FF, opt.order, opt.rank);

% Triangularize transition matrix, compute eigenvalues and stability
this = schur(this);

% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested.
this.Cross = double(opt.cross);
if this.Cross < 1
    index = logical( eye(size(this.Sigma)) );
    this.Sigma(~index) = this.Cross*this.Sigma(~index);
end

if nargout>1
    lsy = get(this, 'ynames');
    D = myoutpdata(this, range, y0, [ ], lsy);
end

if nargout>2
    % Common components.
    CC = FAVAR.cc(this.C, FF);
    CC = FAVAR.destandardise(this.Mean, this.Std, CC);
    CC = myoutpdata(this, range, CC, [ ], lsy);
end

if nargout>3
    % Factors.
    FF = replace(TEMPLATE_SERIES, permute(FF, [2, 1, 3]), range(1));
end

if nargout>4
    % Idiosyncratic residuals.
    U = FAVAR.destandardise(0, this.Std, U);
    U = myoutpdata(this, range, U, [ ], lsy);
end

if nargout>5
    % Residuals from the factor VAR.
    E = replace(TEMPLATE_SERIES, permute(E, [2, 1, 3]), range(1));
end

if nargout>6
    % Contributions to the factors.
    CTF = replace(TEMPLATE_SERIES, permute(CTF, [2, 1, 3]), range(1));
end

if nargout>7
    range = range(sample);
end

end
