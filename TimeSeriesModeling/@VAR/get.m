function varargout = get(This,varargin)
% get  Query VAR object properties.
%
% Syntax
% =======
%
%     Ans = get(V,Query)
%     [Ans,Ans,...] = get(V,Query,Query,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% * `Query` [ char ] - Query to the VAR object.
%
% Output arguments
% =================
%
% * `Ans` [ ... ] - Answer to the query.
%
% Valid queries to VAR objects
% =============================
%
% VAR variables
% --------------
%
% * `'yList'` - Returns [ cellstr ] the names of endogenous variables.
%
% * `'eList'` - Returns [ cellstr ] the names of residuals or shocks.
%
% * `'iList'` - Returns [ cellstr ] the names of conditioning (forecast)
% instruments.
%
% * `'ny'` - Returns [ numeric ] the number of variables.
%
% * `'ne'` - Returns [ numeric ] the number of residuals or shocks.
%
% * `'ni'` - Returns [ numeric ] the number of conditioning (forecast)
% instruments.
%
% System matrices
% ----------------
%
% * `'A#'`, `'A*'`, `'A$'` - Returns [ numeric ] the transition matrix in
% one of the three possible forms; see Description.
%
% * `'K'`, `'const'` - Returns [ numeric ] the constant vector or matrix
% (the latter for panel VARs).
%
% * `'J'` - Returns [ numeric ] the coefficient matrix in front of
% exogenous inputs.
%
% * `'Omg'`, `'Omega'` - Returns [ numeric ] the covariance matrix of
% one-step-ahead forecast errors, i.e. reduced-form residuals. Note that
% this query returns the same matrix also for structural VAR (SVAR)
% objects.
%
% * `'Sgm'`, `'Sigma'` - Returns [ numeric ] the covariance matrix of the
% VAR parameter estimates; the matrix is non-empty only if the option
% `'covParam='` has been set to `true` at estimation time.
%
% * `'G'` - Returns [ numeric ] the coefficient matrix on cointegration
% terms.
%
% Information criteria
% ----------------------
%
% * `'AIC'` - Returns [ numeric ] Akaike information criterion.
%
% * `'AICc'` - Returns [ numeric ] Akaike information criterion corrected
% for small sample.
%
% * `'SBC'` - Returns [ numeric ] Schwarz bayesian criterion.
%
% Other queries
% --------------
% 
% * `'cumLong'` - Returns [ numeric ] the matrix of long-run cumulative
% responses.
%
% * `'nFree'` - Returns [ numeric ] the number of freely estimated (hyper-)
% parameters.
%
% * `'order'`, `'p'` - Returns [ numeric ] the order of the VAR object.
%
% Description
% ============
%
% Transition matrix
% ------------------
%
% There are three queries to request the VAR transition matrix: `'A#'`,
% `'A*'`, `'A$'`. They differ in how the higher-order transition matrices
% are arranged.
%
% * `'A#'` returns `cat(3,I,-A1,...,-Ap)` where `I` is an identity matrix,
% and `A1`, ... `Ap` are the coefficient matrices on individual lags.
%
% * `'A#'` returns `cat(3,A1,...,Ap)` where `A1`, ... `Ap` are the
% coefficient matrices on individual lags.
%
% * `'A$'` returns `[A1,...,Ap]` where `A1`, ... `Ap` are the coefficient
% matrices on individual lags.
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = get@iris.mixin.GetterSetter(This,varargin{:});

end
