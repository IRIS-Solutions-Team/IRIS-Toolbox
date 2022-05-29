% include  Include text or LaTeX input file in the report.
%
% Syntax
% =======
%
%     P.include(Caption,FileName,...)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the function
% [`report.new`](report/new).
%
% * `Caption` [ char ] - Caption displayed at the top of the file included.
%
% * `FileName` [ char ] - File name that will be included here.
%
% Options
% ========
%
% * `'centering='` [ `true` | *`false`* ] - (Inheritable from parent objects)
% Centre the content of the file on the page.
%
% * `'separator='` [ char | *empty* ] - (Not inheritable from parent
% objects) \LaTeX\ commands that will be inserted after the table.
%
% * `'typeface='` [ char | *empty* ] - (Not inheritable from parent objects)
% \LaTeX\ code specifying the typeface for the include element as a whole; it
% must use the declarative forms (such as `\itshape`) and not the command
% forms (such as `\textit{...}`).
%
% * `'verbatim='` [ `true` | *`false`* ] - (Not inheritable from parent objects)
% Enclose the content of the file in a verbatim environment.
%
% Generic options
% ================
%
% See help on [generic options](report/Contents) in report objects.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
