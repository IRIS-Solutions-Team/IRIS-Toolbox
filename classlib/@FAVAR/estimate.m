function [This, D, CC, FF, U, E, CTF, Rng] = estimate(This, varargin)
% estimate  Estimate FAVAR using static principal components.
%
%
% Syntax
% =======
%
%     [A,D,CC,F,U,E,CTF] = estimate(A,D,Range,[R,Q],...)
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
% * `'cross='` [ *`true`* | `false` | numeric ] - Keep off-diagonal
% elements in the covariance matrix of idiosyncratic residuals; if false
% all cross-covariances are reset to zero; if a number between zero and
% one, all cross-covariances are multiplied by that number.
%
% * `'order='` [ numeric | *1* ] - Order of the VAR for factors.
%
% * `'output='` [ *`'auto'`* | `'dbase'` | `'tseries'` ] - Format of output
% data.
%
% * `'rank='` [ numeric | *`Inf`* ] - Restriction on the rank of the factor
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TEMPLATE_SERIES = Series( );

%--------------------------------------------------------------------------

% Get input data.
[y, Rng, yNames, inpFmt, varargin] = myinpdata(This, varargin{:});

if isempty(This.YNames) && isequal(inpFmt, 'dbase')
    % ##### Nov 2013 OBSOLETE and scheduled for removal.
    This.YNames = yNames;
end

This.Range = Rng;

% Parse required input arguments.
crit = varargin{1};
varargin(1) = [ ];

% Parse and validate options.
opt = passvalopt('FAVAR.estimate', varargin{:});

% Determine format of output data.
if strcmpi(opt.output, 'auto')
    outpFmt = inpFmt;
else
    outpFmt = opt.output;
end

%--------------------------------------------------------------------------

% Standardise input data.
y0 = y;
[This, y] = standardise(This, y);

% Estimate static factors using principal components.
[FF, This.C, U, This.Sigma, This.SingVal, sample, CTF] = ...
    FAVAR.pc(y, crit, opt.method);

% Estimate VAR(p,q) on factors.
[This.A, This.B, This.Omega, This.T, This.U, E, This.IxFitted] = ...
    FAVAR.estimatevar(FF, opt.order, opt.rank);
This.EigVal = ordeig(This.T);

% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested.
This.Cross = double(opt.cross);
if This.Cross < 1
    index = logical( eye(size(This.Sigma)) );
    This.Sigma(~index) = This.Cross*This.Sigma(~index);
end

if nargout > 1
    yNames = get(This, 'ynames');
    D = myoutpdata(This, outpFmt, Rng, y0, [ ], yNames);
end

if nargout > 2
    % Common components.
    CC = FAVAR.cc(This.C, FF);
    CC = FAVAR.destandardise(This.Mean, This.Std,CC);
    CC = myoutpdata(This, outpFmt, Rng, CC, [ ], yNames);
end

if nargout > 3
    % Factors.
    FF = replace(TEMPLATE_SERIES, permute(FF,[2,1,3]), Rng(1));
end

if nargout > 4
    % Idiosyncratic residuals.
    U = FAVAR.destandardise(0, This.Std, U);
    U = myoutpdata(This, outpFmt, Rng, U, [ ], yNames);
end

if nargout > 5
    % Residuals from the factor VAR.
    E = replace(TEMPLATE_SERIES, permute(E,[2,1,3]), Rng(1));
end

if nargout > 6
    % Contributions to the factors.
    CTF = replace(TEMPLATE_SERIES, permute(CTF,[2,1,3]), Rng(1));
end

if nargout > 7
    Rng = Rng(sample);
end

end
