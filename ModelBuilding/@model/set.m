function this = set(this, varargin)
% set  Change settable model object property.
%
% Syntax
% =======
%
%     M = set(M,Request,Value)
%     M = set(M,Request,Value,Request,Value,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Request` [ char ] - Name of a modifiable model object property that
% will be changed.
%
% * `Value` [ ... ] - Value to which the property will be set.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with the requested property or properties
% modified.
%
% Valid requests to model objects
% ================================
%
% Equation labels and aliases
% ----------------------------
%
% * `'yLabels='`, `'xLabels='`, `'dLabels='`, `'lLabels='` [ cellstr ] -
% Change the labels attached to, respectively, measurement equations (`y`),
% transition equations (`x`), deterministic trends (`d`), and dynamic links
% (`d`).
%
% * `'labels='` [ cell ] - Change the labels attached to all equations;
% needs to be a cellstr matching the size of `get(M,'labels')`.
%
% * `'yeqtnAlias='`, `'xeqtnAlias='`, `'deqtnAlias='`, `'leqtnAlias='` [
% cellstr ] - Change the aliases of, respectively, measurement equations
% (`y`), transition equations (`x`), deterministic trends (`d`), and
% dynamic links (`d`).
%
% * `'eqtnAlias='` [ cell ] - Change the aliases of all equations; needs to
% be a cellstr matching the size of `get(M,'eqtnAlias')`.
%
% Descriptions and aliases of variables, shocks, and parameters
% --------------------------------------------------------------
%
% * `'yDescript='`, `'xDescript='`, `'eDescript='`, `'pDescript='` [
% cellstr ] - Change the descriptions of, respectively, measurement
% variables (`y`), transition variables (`x`), shocks (`e`), and exogenous
% variables (`g`).
%
% * `'descript='` [ struct ] - Change the descriptions of all variables,
% parameters, and shocks; needs to be a struct (database) with fields
% corresponding to model names.
%
% * `'yAlias='`, `'xAlias='`, `'eAlias='`, `'pAlias='` [ cellstr ] - Change
% the aliases of, respectively, measurement variables (`y`), transition
% variables (`x`), shocks (`e`), and exogenous variables (`g`).
%
% * `'alias='` [ struct ] - Change the aliases of all variables,
% parameters, and shocks; needs to be a struct (database) with fields
% corresponding to model names.
%
% Other requests
% ---------------
%
% * `'nAlt='` [ numeric ] - Change the number of alternative
% parameterisations.
%
% * `'stdVec='` [ numeric ] - Change the whole vector of std deviations.
%
% * `'tOrigin='` [ numeric ] - Change the base year for computing
% deterministic time trends in measurement variables.
%
% * `'epsilon='` [ numeric ] - Change the relative differentiation step
% when computing Taylor expansion.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

this = set@shared.GetterSetter(this, varargin{:});

end
