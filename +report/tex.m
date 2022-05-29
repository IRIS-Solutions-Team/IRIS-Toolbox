% tex  Include \LaTeX\ code or verbatim input in report.
%
% Syntax with input specified in comment block
% =============================================
%
%     P.tex(Cap,...)
%
%     %{
%     Write text or \LaTeX\ code as a block comment
%     right after the P.tex( ) command.
%     %}
%
%
% Syntax with input specified as char argument
% =============================================
%
%     P.tex(Cap, Code,...)
%
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Cap` [ char ] - Caption displayed at the top of the text.
%
% * `Code` [ char ] - \LaTeX\ code or text input that will be included in
% the report.
%
%
% Options
% ========
%
% * `'centering='` [ `true` | *`false`* ] - (Inheritable from parent
% objects) Centre the \LaTeX\ code or text input on the page.
%
% * `'footnote='` [ char | *empty* ] - Footnote at the tex block title;
% only shows if the title is non-empty.
%
% * `'separator='` [ char | *`'\medskip\par'`* ] - (Inheritable from parent
% objects) LaTeX commands that will be inserted after the text.
%
% * `'verbatim='` [ `true` | *`false`* ] - If true the text will be typeset
% verbatim in monospaced font; if false the text will be treated as \LaTeX\
% code included in the report.
%
%
% Generic options
% ================
%
% See help on [generic options](report/Contents) in report objects.
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
% -Copyright (c) 2007-2022 IRIS Solutions Team.
