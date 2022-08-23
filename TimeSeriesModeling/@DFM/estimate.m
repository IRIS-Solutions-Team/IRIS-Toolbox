
%{
% estimate  Estimate DFM using static principal components.
%
% __Syntax__
%
%     [A, D, CC, F, U, E, ctf] = estimate(A, D, Range, [R, Q], ...)
%
%
% __Input Arguments__
%
% * `A` [ DFM ] - Empty DFM object.
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
% __Output Arguments__
%
% * `A` [ DFM ] - Estimated DFM object.
%
% * `D` [ struct ] - Output database.
%
% * `CC` [ tseries ] - Estimates of common components in the DFM
% observables.
%
% * `F` [ tseries ] - Estimates of factors.
%
% * `U` [ struct | tseries ] - Idiosyncratic residuals.
%
% * `E` [ tseries ] - Factor VAR residuals.
%
% * `ctf` [ tseries ] - Contributions of individual input series to the
% estimated factors.
%
%
% __Options__
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
% __Description__
%
%
% __Example__
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, D, CC, FF, U, E, ctf, range] = estimate(this, d, range, crit, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser('DFM.estimate');
    ip.addRequired('DFM', @(x) isa(x, 'DFM'));
    ip.addRequired('InputData', @isstruct);
    ip.addRequired('Range', @validate.range);
    ip.addRequired('RQ', ...
        @(x) isnumeric(x) && numel(x)==2 && x(1)>0 && x(1)<=1 && x(2)==round(x(2)) && x(2)>=1);
    ip.addParameter('Cross', true, ...
        @(x) isequal(x, true) || isequal(x, false) || (isnumeric(x) && isscalar(x) && x>=0 && x<=1));
    ip.addParameter('Method', 'auto', @(x) all(strcmpi(x, 'auto')) || isequal(x, 1) || isequal(x, 2));
    ip.addParameter('Order', 1, @(x) isnumeric(x) && isscalar(x))
    ip.addParameter('Rank', Inf, @(x) isnumeric(x) && isscalar(x));
end
opt = ip.parse(this, d, range, crit, varargin{:});

TEMPLATE_SERIES = Series();


% Get input data.
[y, range] = getEstimationData(this, d, range);
this.Range = range;

% Standardize input data
y0 = y;
[this, y] = stdize(this, y);

% Estimate static factors using principal components.
[FF, this.C, U, this.Sigma, this.SingVal, sample, ctf] = ...
    DFM.pc(y, crit, opt.Method);

% Estimate VAR(p, q) on factors.
[this.A, this.B, this.Omega, E, this.IxFitted] = ...
    DFM.estimatevar(FF, opt.Order, opt.Rank);

% Triangularize transition matrix, compute eigenvalues and stability
this = schur(this);

% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested.
this.Cross = double(opt.Cross);
if this.Cross < 1
    index = logical( eye(size(this.Sigma)) );
    this.Sigma(~index) = this.Cross*this.Sigma(~index);
end

if nargout>1
    D = myoutpdata(this, range, y0, [ ], this.ObservedNames);
end

if nargout>2
    % Common components
    CC = DFM.cc(this.C, FF);
    CC = DFM.destdize(CC, this.Mean, this.Std); 
    CC = myoutpdata(this, range, CC, [ ], this.ObservedNames);
end

if nargout>3
    % Factors.
    FF = replace(TEMPLATE_SERIES, permute(FF, [2, 1, 3]), range(1));
end

if nargout>4
    % Idiosyncratic residuals
    U = DFM.destdize(U, 0, this.Std);
    U = myoutpdata(this, range, U, [ ], this.ObservedNames);
end

if nargout>5
    % Residuals from the factor VAR.
    E = replace(TEMPLATE_SERIES, permute(E, [2, 1, 3]), range(1));
end

if nargout>6
    % Contributions to the factors.
    ctf = replace(TEMPLATE_SERIES, permute(ctf, [2, 1, 3]), range(1));
end

if nargout>7
    range = range(sample);
end

end
