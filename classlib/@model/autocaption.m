function C = autocaption(this, inp, template, varargin)
% autocaption  Create captions for reporting model variables or parameters.
%
% Syntax
% =======
%
%     C = autocaption(M,X,Template,...)
%
%
% Input arguments
% ================
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
% Output arguments
% =================
%
% * `C` [ cellstr ] - Cell array of captions, with one for each model name
% (variable, shock, parameter) found in `X`, in order of their appearance
% in `X`.
%
%
% Options
% ========
%
% * `'corr='` [ char | *`'Corr $shock1$ X $shock2$'`* ] - Template to
% create `$descript$` and `$alias$` for correlation coefficients based on
% `$descript$` and `$alias$` of the underlying shocks.
%
% * `'std='` [ char | *`'Std $shock$'`* ] - Template to create
% `$descript$` and `$alias$` for std deviation based on `$descript$` and
% `$alias$` of the underlying shock.
%
%
% Description
% ============
%
% The function `autocaption` can be used to supply user-created captions to
% title graphs in `grfun/plotpp`, `grfun/plotneigh`, `model/shockplot`,
% and `dbase/dbplot`, through their option `'caption='`.
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
% The options `'corr='` and `'std='` will be used to create `$descript$`
% and `$alias$ for std deviations and cross-correlations of shocks (which
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
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

opt = passvalopt('model.autocaption',varargin{:});
C = generateAutocaption(this.Quantity, inp, template, opt);

end
