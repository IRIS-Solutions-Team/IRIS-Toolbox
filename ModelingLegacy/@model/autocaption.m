function captions = autocaption(this, inp, template, varargin)
% autocaption  Create captions for reporting model variables or parameters.
%
% ## Syntax ##
%
%     c = autocaption(m, x, template, ...)
%
%
% ## Input Arguments ##
%
% * `m` [ model ] - Model object.
%
% * `x` [ cellstr | struct | Posterior ] - A cell array of model names, a
% struct with model names, or a [`Posterior`](../posterior-objects/README.md)
% object.
%
% * `template` [ char ] - Prescription for how to create the caption; see
% Description for details.
%
%
% ## Output Arguments ##
%
% * `c` [ cellstr | string ] - Cell array or string array of captions, with
% one for each model name (variable, shock, parameter) found in `x`, in
% order of their appearance in `x`.
%
%
% ## Options ##
%
% ##### `Corr='Corr $shock1$ X $shock2$'`
%
% [ char ] 
%
% Template to create
% `$descript$` and `$alias$` for correlation coefficients based on
% `$descript$` and `$alias$` of the underlying shocks.
%
% ##### `Std='Std $shock$'`
%
% [ char ] 
%
% Template to create `$descript$` and
% `$alias$` for std deviation based on `$descript$` and `$alias$` of the
% underlying shock.
%
%
% ## Description ##
%
% The function `autocaption( )` is used to supply user-created captions to
% title graphs in `grfun/plotpp`, `grfun/plotneigh`, `model/shockplot`, 
% and `dbase/dbplot`, through their option `Caption=`.
%
% The `template` can contain the following substitution strings:
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
% The options `Corr=` and `Std=` are used to create `$descript$`
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
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

opt = passvalopt('model.autocaption', varargin{:});
captions = generateAutocaption(this.Quantity, inp, template, opt);

end
