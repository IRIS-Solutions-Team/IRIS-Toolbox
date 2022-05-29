function this = set(this, varargin)
% set  Change settable model object property.
%
% ## Syntax ##
%
%     M = set(M, Request, Value)
%     M = set(M, Request, Value, Request, Value, ...)
%
% ## Input arguments ##
%
% * `M` [ model ] - Model object.
%
% * `Request` [ char ] - Name of a modifiable model object property that
% will be changed.
%
% * `Value` [ ... ] - Value to which the property will be set.
%
%
% ## Output Arguments ##
%
% * `M` [ model ] - Model object with the requested property or properties
% modified.
%
%
% ## Valid Requests to Model Objects ##
%
% _Equation Labels and Aliases_
%
% * `'YLabels='`, `'XLabels='`, `'DLabels='`, `'LLabels='` [ cellstr ] -
% Change the labels attached to, respectively, measurement equations (`Y`), 
% transition equations (`X`), deterministic trends (`D`), and dynamic links
% (`D`).
%
% * `'Labels='` [ cell ] - Change the labels attached to all equations;
% needs to be a cellstr matching the size of `get(M, 'labels')`.
%
% * `'YeqtnAlias='`, `'XeqtnAlias='`, `'DeqtnAlias='`, `'LeqtnAlias='` [
% cellstr ] - Change the aliases of, respectively, measurement equations
% (`Y`), transition equations (`X`), deterministic trends (`D`), and
% dynamic links (`L`).
%
% * `'EqtnAlias='` [ cell ] - Change the aliases of all equations; needs to
% be a cellstr matching the size of `get(M, 'eqtnAlias')`.
%
%
% _Descriptions and Aliases of Variables, Shocks, and Parameters_
%
% * `'YDescript='`, `'XDescript='`, `'EDescript='`, `'PDescript='` [
% cellstr ] - Change the descriptions of, respectively, measurement
% variables (`Y`), transition variables (`X`), shocks (`E`), and exogenous
% variables (`G`).
%
% * `'Descript='` [ struct ] - Change the descriptions of all variables, 
% parameters, and shocks; needs to be a struct (database) with fields
% corresponding to model names.
%
% * `'YAlias='`, `'XAlias='`, `'EAlias='`, `'PAlias='` [ cellstr ] - Change
% the aliases of, respectively, measurement variables (`Y`), transition
% variables (`X`), shocks (`E`), and exogenous variables (`G`).
%
% * `'Alias='` [ struct ] - Change the aliases of all variables, 
% parameters, and shocks; needs to be a struct (database) with fields
% corresponding to model names.
%
% _Other Requests_
%
% * `'NAlt='` [ numeric ] - Change the number of alternative
% parameterisations.
%
% * `'StdVec='` [ numeric ] - Change the whole vector of std deviations.
%
% * `'BaseYear='` [ numeric ] - Change the base year for computing
% deterministic time trends in measurement variables.
%
% * `'Epsilon='` [ numeric ] - Change the relative differentiation step
% when computing Taylor expansion.
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

this = set@iris.mixin.GetterSetter(this, varargin{:});

end%

