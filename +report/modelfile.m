% modelfile  Write formatted model file.
%
% Syntax
% =======
%
%     P.modelfile(Caption,FileName,...)
%     P.modelfile(Caption,FileName,M,...)
%
% Input arguments
% ================
%
% * `P` [ report ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Caption` [ char | cellstr ] - Title and subtitle displayed at the top
% of the table.
%
% * `FileName` [ char ] - Model file name.
%
% * `M` [ model ] - Model object from which the values of parameters and
% std devs of shocks will be read; if missing no parameter values or std
% devs will be printed.
%
% Options
% ========
%
% * `'latexAlias='` [ `true` | *`false`* ] - Treat alias in labels as LaTeX
% code and typeset it that way.
%
% * `'lines='` [ numeric | *`@all`* ] - Print only selected lines of the
% model file `FileName`; `@all` means all lines will be printed.
%
% * `'lineNumbers='` [ *`true`* | `false` ] - Display line numbers.
%
% * `'footnote='` [ char | *empty* ] - Footnote at the model file title;
% only shows if the title is non-empty.
%
% * `'paramValues='` [ *`true`* | `false` ] - Display the values of parameters
% and std devs of shocks next to each occurence of a parameter or a shock;
% this option works only if a model object `M` is entered as the 3rd input
% argument.
%
% * `'syntax='` [ *`true`* | `false` ] - Highlight model file syntax; this
% includes model language keywords, descriptions of variables, shocks and
% parameters, and equation labels.
%
% * `'typeface='` [ char | *empty* ] - (Not inheritable from parent
% objects) LaTeX code specifying the typeface for the model file as a
% whole; it must use the declarative forms (such as `\itshape`) and not the
% command forms (such as `\textit{...}`).
%
% Description
% ============
%
% If you enter a model object with multiple parameterisations, only the
% first parameterisation will get reported.
%
% At the moment, the syntax highlighting in model file reports does not
% handle correctly comment blocks, i.e. `%{ ... %}`.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
