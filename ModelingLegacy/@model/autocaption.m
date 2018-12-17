function captions = autocaption(this, inp, template, varargin)
% autocaption  Create captions for reporting model variables or parameters.
%
% __Syntax__
%
%     C = autocaption(M, X, Template, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object.
%
% * `X` [ cellstr | struct | poster ] - A cell array of model names, a
% struct with model names, or a [`poster`](poster/Contents) object.
%
% * `Template` [ char ] - Prescription for how to create the caption; see
% Description for details.
%
%
% __Output Arguments__
%
% * `C` [ cellstr | string ] - Cell array or string array of captions, with
% one for each model name (variable, shock, parameter) found in `X`, in
% order of their appearance in `X`.
%
%
% __Options__
%
% * `Corr='Corr $shock1$ X $shock2$'` [ char ] - Template to create
% `$descript$` and `$alias$` for correlation coefficients based on
% `$descript$` and `$alias$` of the underlying shocks.
%
% * `Std='Std $shock$'` [ char ] - Template to create `$descript$` and
% `$alias$` for std deviation based on `$descript$` and `$alias$` of the
% underlying shock.
%
%
% __Description__
%
% The function `autocaption( )` is used to supply user-created captions to
% title graphs in `grfun/plotpp`, `grfun/plotneigh`, `model/shockplot`, 
% and `dbase/dbplot`, through their option `Caption=`.
%
% The `Template` can contain the following substitution strings:
%
% * `$name$` -- will be replaced with the name of the respective variable, 
% shock, or parameter;
%
% * `$label$` -- will be replaced with the description of the respective
% variable, shock, or parameter;
%
% * `$alias$` -- will be replaced with the alias of the respective
% variable, shock, or parameter.
%
% The options `Corr=` and `Std=` will be used to create `$descript$`
% and `$alias$` for std deviations and cross-correlations of shocks (which
% cannot be created in the model code). The options are expected to use the
% following substitution strings:
%
% * `'$shock$'` -- will be replaced with the description or alias of the
% underlying shock in a std deviation;
%
% * `'$shock1$'` -- will be replaced with the description or alias of the
% first underlying shock in a cross correlation;
%
% * `'$shock2$'` -- will be replaced with the description or alias of the
% second underlying shock in a cross correlation.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

opt = passvalopt('model.autocaption', varargin{:});
captions = generateAutocaption(this.Quantity, inp, template, opt);

end
