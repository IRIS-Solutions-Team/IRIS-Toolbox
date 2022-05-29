% matrix  Insert matrix or numeric array.
%
% Syntax
% =======
%
%     P.matrix(Caption,Data,...)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Caption` [ char | cellstr ] - Title or a cell array with title and
% subtitle displayed at the top of the matrix; see Description for
% splitting the title or subtitle into multiple lines.
%
% * `Data` [ numeric ] - Numeric array with input data.
%
% Options
% ========
%
% * `'arrayStretch='` [ numeric | *`1.15`* ] - (Inheritable from parent
% objects) Stretch between lines in the matrix (in pts).
%
% * `'captionTypeface='` [ cellstr | char | *'\large\bfseries'* ] - \LaTeX\
% format commands for typesetting the matrix caption; the subcaption format
% can be entered as the second cell in a cell array.
%
% * `'colNames='` [ cellstr | *empty* ] - (Inheritable from parent objects)
% Names for individual matrix columns, displayed at the top of the matrix.
%
% * `'colWidth='` [ numeric | *`NaN`* ] - (Inheritable from parent objects)
% Width, or a vector of widhts, of the matrix columns in `em `units; `NaN`
% means the width of the column will adjust automatically.
%
% * `'condFormat='` [ struct | *empty* ] - (Inheritable from parent
% objects) Structure with .test and .format fields describing
% conditional formatting of individual matrix entries.
%
% * `'footnote='` [ char | *empty* ] - Footnote at the matrix title; only
% shows if the title is non-empty.
%
% * `'format='` [ char | *`'%.2f'`* ] - (Inheritable from parent objects)
% Numeric format string; see help on the built-in `sprintf` function.
%
% * `'heading='` [ char | *empty* ] - (Inheritable from parent objects)
% User-supplied heading, i.e. an extra row or rows at the top of the
% matrix.
%
% * `'inf='` [ char | *`'$\infty$'`* ] - (Inheritable from parent objects)
% \LaTeX\ string that will be used to typeset Infs.
%
% * `'long='` [ `true` | *`false`* ] - (Inheritable from parent objects) If
% `true`, the matrix may stretch over more than one page.
%
% * `'longFoot='` [ char | *empty* ] - (Inheritable from parent objects)
% Works only with `'long='` `true`: Footnote that appears at the bottom of
% the matrix (if it is longer than one page) on each page except the last
% one.
%
% * `'longFootPosition='` [ `'centre'` | *`'left'`* | `'right'` ] - (Inheritable
% from parent objects) Works only with `'long='` `true`: Horizontal alignment
% of the footnote in long matrices.
%
% * `'nan='` [ char | *`'$\cdots$'`* ] - (Inheritable from parent objects)
% \LaTeX\ string that will be used to typeset `NaN`s.
%
% * `'pureZero='` [ char | *empty* ] - (Inheritable from parent objects)
% \LaTeX\ string that will be used to typeset pure zero entries; if empty the
% zeros will be printed using the current numeric format.
%
% * `'printedZero='` [ char | *empty* ] - (Inheritable from parent objects)
% \LaTeX\ string that will be used to typeset the entries that would appear
% as zero under the current numeric format used; if empty these numbers
% will be printed using the current numeric format.
%
% * `'rotateColNames='` [ *`true`* | `false` | numeric ] - Rotate the
% names of columns by the specified number of degrees; `true` means
% rotate by 90 degrees.
%
% * `'rowNames='` [ cellstr | *empty* ] - (Inheritable from parent objects)
% Names fr individual matrix rows, displayed left of the matrix.
%
% * `'separator='` [ char | *`'\medskip\par'`* ] - (Inheritable from parent
% objects) \LaTeX\ commands that will be inserted after the matrix.
%
% * `'sideways='` [ `true` | *`false`* ] - (Inheritable from parent objects)
% Print the matrix rotated by 90 degrees.
%
% * `'tabcolsep='` [ `NaN` | numeric ] - (Inheritable from parent objects)
% Space between columns in the matrix, measured in em units; `NaN` means the
% \LaTeX\ default.
%
% * `'typeface='` [ char | *empty* ] - (Not inheritable from parent objects)
% \LaTeX\ code specifying the typeface for the matrix as a whole; it must use
% the declarative forms (such as `\itshape`) and not the command forms
% (such as `\textit{...}`).
%
% Generic options
% ================
%
% See help on [generic options](report/Contents) in report objects.
%
% Description
% ============
%
% Conditional formatting
% ------------------------
%
% The conditional format struct (or an array of structs) specified through
% the `'condFormat='` option must have two fields, `.test` and `.format`.
%
% The `.test` field is a text string with a Matlab expression. The
% expression must evaluate to a scalar `true` or `false`, and can refer to the
% following attributes associated with each entry in the data part of the
% matrix:
%
% * `value` - the numerical value of the entry;
% * `row` - the row number within the data part of the matrix;
% * `col` - the column number within the data part of the matrix;
% * `rowname` - the row name right of which the entry appears;
% * `colname` - the column name under which the entry appears;
% * `rowvalues` - a row vector of all values in the current row;
% * `colvalues` - a column vector of all values in the current column;
% * `allvalues` - a matrix of all values.
%
% You can combine a number of attribues within one test, using the logical
% operators, e.g.
%
%     value > 0 && row > 3
%     value == max(rowvalues) && strcmp(rowname,'x')
%
% The `.format` fields of the conditional format structure consist of LaTeX
% commands that will be use to typeset the corresponding entry. The
% reference to the entry itself is through a question mark. The entries are
% typeset in math mode; this for instance meanse that for bold or italic
% typface, you must use the `\mathbf{...}` and `\mathit{...}` commands.
%
% In addition to standard LaTeX commands, you can use the following IRIS
% commands in the format strings:
%
% * `\sprintf{FFFF}` - to modify the way each numeric entry that passes
% the test is printed by the `sprintf` function; `FFFF` is one of the
% standard sprintf formattting strings.
%
% You can combine multiple tests and their correponding formats in one
% structure; they will be all applied to each entry in the specified order.
%
% Titles and subtitles
% ---------------------
%
% The input argument `Caption` can be either a text string, or a 1-by-2
% cell array of strings. In the latter case, the first cell will be printed
% as a title, and the second cell will be printed as a subtitle.
%
% To split the title or subtitle into multiple lines, use the following
% LaTeX commands wrapped in curly brackets: `{\\}` or `{\\[Xpt]}`, where
% `X` is the width of an extra vertical space (in points) added between the
% respective lines.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
