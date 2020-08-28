function varargout = get(this, varargin)
% get  Query model object properties.
%
% __Syntax__
%
%     Ans = get(M, Query)
%     [Ans, Ans, ...] = get(M, Query, Query, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object.
%
% * `Query` [ char ] - Query to the model object.
%
%
% __Output Arguments__
%
% * `Ans` [ ... ] - Answer to the query.
%
%
% __Valid Queries to Model Objects__
%
% This is the categorised list of queries to model objects. Note that
% letter `'Y'` is used in various contexts to denote measurement variables
% or equations, `'X'` transition variables or equations, `'E'` shocks,
% `'P'` parameters, `'G'` exogenous variables, `'D'` deterministic trend
% equations, and `'L'` dynamic links. The names are case insensitive.
%
% _Steady State_
%
% * `'Steady'` - Returns [ struct ] a database with the steady states for all
% model variables. The steady states are described by complex numbers in
% which the real part is the level and the imaginary part is the growth
% rate.
%
% * `'SteadyLevel'` - Returns [ struct ] a database with the steady-state
% levels for all model variables.
%
% * `'SteadyGrowth'` - Returns [ struct ] a database with steady-state
% growth (first difference for linearised variables, gross rate of growth
% for log-linearised variables) for all model variables.
%
% * `'DTrends'` - Returns [ struct ] a database with the effect of the
% deterministic trends on the measurement variables. The effect is
% described by complex numbers the same way as the steady state.
%
% * `'DTrendsLevel'` - Returns [ struct ] a database with the effect of the
% deterministic trends on the steady-state levels of the measurement
% variables.
%
% * `'DTrendsGrowth'` - Returns [ struct ] a database with the effect of
% deterministic trends on steady-state growth of the measurement variables.
%
% * `'Steady+DTrends'` - Returns [ struct ] the same as 'Sstate' except
% that the measurement variables are corrected for the effect of the
% deterministic trends.
%
% * `'SstateLevel+DtrendsLevel'` - Returns [ struct ] the same as
% 'SstateLevel' except that the measurement variables are corrected for the
% effect of the deterministic trends.
%
% * `'SstateGrowth+DtrendsGrowth'` - Returns [ struct ] the same as
% `'SstateGrowth'` except that the measurement variables are corrected for
% the effect of the deterministic trends.
%
%
% _Variables, Shocks, and Parameters_
%
% * `'YList'`, `'XList'`, `'EList'`, `'PList'`, `'GList'` - Return [
% cellstr ] the lists of, respectively, measurement variables (`Y`), 
% transition variables (`X`), shocks (`E`), parameters (`P`), and exogenous
% variables (`G`), each in order of appearance of the names in declaration
% sections of the original model file. Note that the list of parameters, 
% `'PList'`, does not include the names of std deviations or
% cross-correlations.
%
% * `'EYList'` - Returns [ cellstr ] the list of measurement shocks in order
% of their appearance in the model code declarations; only those shocks
% that actually occur in at least one measurement equation are returned.
%
% * `'EXList'` - Returns [ cellstr ] the list of transition shocks in order
% of their appearance in the model code declarations; only those shocks
% that actually occur in at least one transition equation are returned.
%
% * `'StdList'` - Returns [ cellstr ] the list of the names of the standard
% deviations for the shocks in order of the appearance of the corresponding
% shocks in the model code.
%
% * `'CorrList'` - Returns [ cellstr ] the list of the names of
% cross-correlation coefficients for the shocks in order of the appearance
% of the corresponding shocks in the model code.
%
% * `'StdCorrList'` - Returns [ cellstr ] the list of the names of std
% deviations and cross-correlation coefficients for the shocks in order of
% the appearance of the corresponding shocks in the model code.
%
% * `'Substitutions'` - Returns [ struct ] a struct with the names and
% bodies of substitutions defined in the source model file(s).
%
%
% _Equations_
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
%
% _First-Order Taylor Expansion of Equations_
%
% * `'Gradients'` - Returns [ struct ] with two nested structures,
% `.Dynamic` and `.Steady` with the gradients for each equation calculaated
% with respect to each variable that occurs in the respective equation.
% Both the `.Dynamic` and the `.Steady` gradients are n-by-2 cell arrays
% where n is the number of equations. The {n, 1} element is a function
% handle returning all derivatives at once; the {n, 2} element is a string
% vector listing the order of the variales w.r.t. which the derivatives are
% calculated.
%
%
% _Descriptions and Aliases of Variables, Parameters, and Shocks_
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
% * `'YAlias'`, `'XAlias'`, `'EAlias'`, `'PAlias'`, `'GAlias'` - Return [
% cellstr ] the aliases of, respectively, measurement variables (`Y`), 
% transition variables (`X`), shocks (`E`), parameters (`P`), and exogenous
% variables (`G`).
%
%
% _Equation Labels and Aliases_
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
%
% _Parameter Values_
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
%
% _Eigenvalues_
%
% * `'StableRoots'` - Returns [ cell of numeric ] a vector of the model
% eigenvalues that are smaller than one in magnitude (allowing for rounding
% errors around one).
%
% * `'UnitRoots'` - Returns [ cell of numeric ] a vector of the model
% eigenvalues that equal one in magnitude (allowing for rounding errors
% around one).
%
% * `'UnstableRoots'` [ cell of numeric ] A vector of the model eigenvalues
% that are greater than one in magnitude (allowing for rounding errors
% around one).
%
%
% _Model Structure, Solution, Build_
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
% __Description__
%
% _First-Order Taylor Expansion of Equations__
%
% The expressions for symbolic/automatic derivatives of individual model
% equations returned by `'Derivatives'` are expressions that evaluate the
% derivatives with respect to all variables present in that equation at
% once. The list of variables with respect to which each equation is
% differentiated is returned by `'Wrt'`.
%
% The expressions returned by the query `'Derivatives'` can refer to
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
% __Example__
%
%     d = get(m, 'Derivatives');
%     w = get(m, 'Wrt');
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
% -Copyright (c) 2007-2020 IRIS Solutions Team.

[varargout{1:nargout}] = get@shared.GetterSetter(this, varargin{:});

end
