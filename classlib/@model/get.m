function varargout = get(this, varargin)
% get  Query model object properties.
%
%
% Syntax
% =======
%
%     Ans = get(M,Query)
%     [Ans,Ans,...] = get(M,Query,Query,...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Query` [ char ] - Query to the model object.
%
%
% Output arguments
% =================
%
% * `Ans` [ ... ] - Answer to the query.
%
%
% Valid queries to model objects
% ===============================
%
% This is the categorised list of queries to model objects. Note that
% letter `'y'` is used in various contexts to denote measurement variables
% or equations, `'x'` transition variables or equations, `'e'` shocks,
% `'p'` parameters, `'g'` exogenous variables, `'d'` deterministic trend
% equations, and `'l'` dynamic links. The property names are case
% insensitive.
%
% Steady state
% -------------
%
% * `'Sstate'` - Returns [ struct ] a database with the steady states for all
% model variables. The steady states are described by complex numbers in
% which the real part is the level and the imaginary part is the growth
% rate.
%
% * `'SstateLevel'` - Returns [ struct ] a database with the steady-state
% levels for all model variables.
%
% * `'SstateGrowth'` - Returns [ struct ] a database with steady-state growth
% (first difference for linearised variables, gross rate of growth for
% log-linearised variables) for all model variables.
%
% * `'Dtrends'` - Returns [ struct ] a database with the effect of the
% deterministic trends on the measurement variables. The effect is
% described by complex numbers the same way as the steady state.
%
% * `'DtrendsLevel'` - Returns [ struct ] a database with the effect of the
% deterministic trends on the steady-state levels of the measurement
% variables.
%
% * `'DtrendsGrowth'` - Returns [ struct ] a database with the effect of
% deterministic trends on steady-state growth of the measurement variables.
%
% * `'Sstate+dtrends'` - Returns [ struct ] the same as 'sstate' except
% that the measurement variables are corrected for the effect of the
% deterministic trends.
%
% * `'SstateLevel+dtrendsLevel'` - Returns [ struct ] the same as
% 'sstateLevel' except that the measurement variables are corrected for the
% effect of the deterministic trends.
%
% * `'SstateGrowth+dtrendsGrowth'` - Returns [ struct ] the same as
% `'sstateGrowth'` except that the measurement variables are corrected for
% the effect of the deterministic trends.
%
% Variables, shocks, and parameters
% ----------------------------------
%
% * `'YList'`, `'XList'`, `'EList'`, `'PList'`, `'GList'` - Return [
% cellstr ] the lists of, respectively, measurement variables (`Y`),
% transition variables (`X`), shocks (`E`), parameters (`P`), and exogenous
% variables (`G`), each in order of appearance of the names in declaration
% sections of the original model file. Note that the list of parameters,
% `'PList'`, does not include the names of std deviations or
% cross-correlations.
%
% * `'eYList'` - Returns [ cellstr ] the list of measurement shocks in order
% of their appearance in the model code declarations; only those shocks
% that actually occur in at least one measurement equation are returned.
%
% * `'eXList'` - Returns [ cellstr ] the list of transition shocks in order
% of their appearance in the model code declarations; only those shocks
% that actually occur in at least one transition equation are returned.
%
% * `'stDList'` - Returns [ cellstr ] the list of the names of the standard
% deviations for the shocks in order of the appearance of the corresponding
% shocks in the model code.
%
% * `'corRList'` - Returns [ cellstr ] the list of the names of
% cross-correlation coefficients for the shocks in order of the appearance
% of the corresponding shocks in the model code.
%
% * `'stdCorRList'` - Returns [ cellstr ] the list of the names of std
% deviations and cross-correlation coefficients for the shocks in order of
% the appearance of the corresponding shocks in the model code.
%
% Equations
% ----------
%
% * `'YEqtn'`, `'XEqtn'`, `'DEqtn'`, `'LEqtn'` - Return [ cellstr ] the
% lists of, respectively, to measurement equations (`Y`), transition
% equations (`X`), deterministic trends (`D`), and dynamic links (`L`),
% each in order of appearance in the original model file.
%
% * `'links'` - Returns [ struct ] a database with the dynamic links with
% fields names after the LHS name.
%
% * `'rpteq'` - Returns [ rpteq ] a reporting equations (rpteq) object (if
% `!reporting_equations` were included in the model file).
%
% First-order Taylor expansion of equations
% ------------------------------------------
%
% * `'derivatives'` - Returns [ cellstr ] the symbolic/automatic
% derivatives for each model equation; in each equation, the derivatives
% w.r.t. all variables present in that equation are evaluated at once and
% returned as a vector of numbers; see also `'wrt'`.
%
% * `'wrt'` -  Returns [ cellstr ] the list of the variables (and their
% auxiliary lags or leads) with respect to which the corresponding
% equation in `'derivatives'` is differentiated.
%
% Descriptions and aliases of variables, parameters, and shocks
% --------------------------------------------------------------
%
% * `'descript'` - Returns [ struct ] a database with user descriptions of
% model variables, shocks, and parameters.
%
% * `'YDescript'`, `'XDescript'`, `'EDescript'`, `'PDescript'`,
% `'GDescript'` - Return [ cellstr ] user descriptions of, respectively,
% measurement variables (`Y`), transition variables (`X`), shocks (`E`),
% parameters (`P`), and exogenous variables (`G`).
%
% * `'Alias'` - Returns [ struct ] a database with all aliases of model
% variables, shocks, and parameters.
%
% * `'yAlias'`, `'xAlias'`, `'eAlias'`, `'pAlias'`, `'gAlias'` - Return [
% cellstr ] the aliases of, respectively, measurement variables (`Y`),
% transition variables (`X`), shocks (`E`), parameters (`P`), and exogenous
% variables (`G`).
%
% Equation labels and aliases
% ----------------------------
%
% * `'Labels'` - Returns [ cellstr ] the list of all user labels added to
% equations.
%
% * `'YLabels'`, `'XLabels'`, `'DLabels'`, `'LLabels'`, `'RLabels'` -
% Return [ cellstr ] user labels added, respectively, to measurement
% equations (`Y`), transition equations (`X`), deterministic trends (`D`),
% dynamic links (`L`), and reporting equations ('R').
%
% * `'EqtnAlias'` - Returns [ cellstr ] the list of all aliases added to
% equations.
%
% * `'YEqtnAlias'`, `'XEqtnAlias'`, `'DEqtnAlias'`, `'LEqtnAlias'`,
% `'REqtnAlias'` - Return [ cellstr ] the aliases of, respectively,
% measurement equations (`Y`), transition equations (`X`), deterministic
% trends (`D`), and dynamic links (`L`).
%
% Parameter values
% -----------------
%
% * `'Corr'` - Returns [ struct ] a database with current cross-correlation
% coefficients of shocks.
%
% * `'NonzeroCorr'` - Returns [ struct ] a database with current nonzero
% cross-correlation coefficients of shocks.
%
% * `'Parameters'` - Returns [ struct ] a database with current parameter
% values, including the std devs and non-zero corr coefficients.
%
% * `'Std'` - Returns [ struct ] a database with current std deviations of
% shocks.
%
% Eigenvalues
% ------------
%
% * `'stableRoots'` - Returns [ cell of numeric ] a vector of the model
% eigenvalues that are smaller than one in magnitude (allowing for rounding
% errors around one).
%
% * `'unitRoots'` - Returns [ cell of numeric ] a vector of the model
% eigenvalues that equal one in magnitude (allowing for rounding errors
% around one).
%
% * `'unstableRoots'` [ cell of numeric ] A vector of the model eigenvalues
% that are greater than one in magnitude (allowing for rounding errors
% around one).
%
% Model structure, solution, build
% ---------------------------------
%
% * `'Build'` - Returns [ numeric ] IRIS version number under which the
% model object has been built.
%
% * `'Log'` - Returns [ struct ] a database with `true` for each
% log-linearised variables, and `false` for each linearised variable.
%
% * `'LogList'` - Returns [ cellstr ] the list of log variables.
%
% * `'MaxLag'` - Returns [ numeric ] the maximum lag in the model.
%
% * `'MaxLead'` - Returns [ numeric ] the maximum lead in the model.
%
% * `'Stationary'` - Returns [ struct ] a database with `true` for each
% stationary variables, and `false` for each unit-root (non-stationary)
% variables (under current solution).
%
% * `'NonStationary'` - Returns [ struct ] a database with `true` for each
% unit-root (non-stationary) varible, and `false` for each stationary
% variable (under current solution).
%
% * `'StationaryList'` - Returns [ cellstr ] the list of stationary
% variables (under current solution).
%
% * `'NonStationaryList'` - Returns [ cellstr ] cell with the list of
% unit-root (non-stationary) variables (under current solution).
%
% * `'InitCond'` - Returns [ cellstr ] the list of the lagged transition
% variables that need to be supplied as initial conditions in simulations
% and forecasts. The list of the initial conditions is solution-specific as
% the state-spece coefficients at some of the lags may evaluate to zero
% depending on the current parameters.
%
% * `'YVector'` - Returns [ cellstr ] the list of measurement variables in
% order of their appearance in the rows and columns of state-space matrices
% (effectively identical to `'YList'`) from the
% [`model/sspace`](model/sspace) function.
%
% * `'XVector'` - Returns [ cellstr ] the list of transition variables, and
% their auxiliary lags and leads, in order of their appearance in the rows
% and columns of state-space matrices from the [`model/sspace`](model/sspace) function.
%
% * `'Xfvector'` - Returns [ cellstr ] the list of forward-looking (i.e.
% non-predetermined) transition variables, and their auxiliary lags and
% leads, in order of their appearance in the rows and columns of
% state-space matrices from the [`model/sspace`](model/sspace) function.
%
% * `'XbVector'` - Returns [ cellstr ] the list of backward-looking (i.e.
% predetermined) transition variables, and their auxiliary lags and leads,
% in order of their appearance in the rows and columns of state-space
% matrices from the [`model/sspace`](model/sspace) function.
%
% * `'EVector'` - Returns [ cellstr ] the list of the shocks in order of
% their appearance in the rows and columns of state-space matrices
% (effectively identical to `'EList'`) from the [`model/sspace`](model/sspace) function.
%
%
% Description
% ============
%
% First-order Taylor expansion of equations
% ------------------------------------------
%
% The expressions for symbolic/automatic derivatives of individual model
% equations returned by `'derivatives'` are expressions that evaluate the
% derivatives with respect to all variables present in that equation at
% once. The list of variables with respect to which each equation is
% differentiated is returned by `'wrt'`.
%
% The expressions returned by the query `'derivatives'` can refer to
%
% * the names of model parameters, such as `alpha`;
% * the names of transition or measurement variables, such as `X`;
% * the lags or leads of variables, such as `X{-1}` or `X{2}`.
%
% Note that the lags and leads of variables must be, in general, preserved
% in the derivatives for non-stationary (unit-root) models. For stationary
% models, the lags and leads can be removed and each simply replaced with
% the current date of the respective variable.
%
%
% Example
% ========
%
%     d = get(m,'derivatives');
%     w = get(m,'wrt');
%
% The 1-by-N cell array `d` (where N is the total number of equations in
% the model) will contain expressions that evaluate to the vector of
% derivatives of the individual equations w.r.t. to the variables present
% in that equation:
%
%     d{k}
%
% is an expression that returns, in general, a vector of M numbers. These M
% numbers are the derivatives of the k-th equation w.r.t to M
% variables whose list is in
%
%     w{k}
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

[varargout{1:nargout}] = get@shared.GetterSetter(this, varargin{:});

end
