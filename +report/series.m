% series  Add new data to graph or table.
%
% Syntax
% =======
%
%     P.series(Cap,X,...)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Cap` [ char | cellstr | `@auto` ] - Caption used as a default legend
% entry in a graph, or in the leading column in a table; `@auto` means that
% the first comment from the input tseries object, `X`, will be used for
% the title.
%
% * `X` [ tseries ] - Input data that will be added to the current table or
% graph.
%
% Options for both table series and graph series
% ===============================================
%
% * `'marks='` [ cellstr | *empty* ] - (Inheritable from parent objects)
% Marks that will be added to the legend entries in graphs, or printed in a
% third column in tables, to distinguish the individual columns of possibly
% multivariate input tseries objects.
%
% * `'showMarks='` [ *`true`* | `false` ] - (Inheritable from parent objects)
% Use the marks defined in the `'marks='` option to label the individual
% rows when input data is a multivariate tseries object.
%
% Options for table series
% =========================
%
% * `'autoData='` [ function_handle | cell | *empty* ] - Function, or a cell
% array of functions, that will be used to produce new columns in the input
% tseries object (i.e. new rows of ouput in the report).
%
% * `'condFormat='` [ struct | *empty* ] - (Inheritable from parent
% objects) Structure with .test and .format fields describing
% conditional formatting of individual table entries.
%
% * `'decimal='` [ numeric | *`NaN`* ] - (Inheritable from parent objects)
% Number of decimals that will be displayed; if NaN the `'format='` option
% is used instead.
%
% * `'format='` [ char | *`'%.2f'`* ] - (Inheritable from parent objects)
% Numeric format string; see help on the built-in `sprintf` function.
%
% * `'footnote='` [ char | *empty* ] - Footnote at the series text.
%
% * `'highlight='` [ numeric | *empty* ] - Periods for which the data
% entries will highlighted.
%
% * `'inf='` [ char | *`'\ensuremath{\infty}'`* ] - (Inheritable from
% parent objects) LaTeX string that will be used to typeset Inf entries.
%
% * `'nan='` [ char | *`'\ensuremath{\cdot}'`* ] - (Inheritable from parent
% objects) LaTeX string that will be used to typeset NaN entries.
%
% * `'pureZero='` [ char | *empty* ] - (Inheritable from parent objects)
% LaTeX string that will be used to typeset pure zero entries; if empty the
% zeros will be printed using the current numeric format.
%
% * `'printedZero='` [ char | *empty* ] - (Inheritable from parent objects)
% LaTeX string that will be used to typeset the entries that would appear
% as zero under the current numeric format used; if empty these numbers
% will be printed using the current numeric format.
%
% * `'rowHighlight='` [ `true` | *`false`* ] - Highlight the entire row,
% including the text, units and marks at the beginnig; because of a bug in
% the LaTex package `colortbl`, this option cannot be combined with the
% option `'highlight='` in [`report/table`](report/table).
%
% * `'separator='` [ char | *empty* ] - LaTeX commands that will be
% inserted immediately after the end of the table row, i.e. appended to \\,
% within a tabular mode.
%
% * `'units='` [ char ] - (Inheritable from parent objects) Description of
% input data units that will be displayed in the second column of tables.
%
% Options for graph series
% =========================
%
% * `'legendEntry='` [ char | cellstr | `NaN` | *`@auto`* ] - Legend
% entries used instead of the series caption and marks; `@auto` means the
% caption and marks will be used to construct legend entries; `NaN` means
% the series will be exluded from legend.
%
% * `'plotFunc='` [ `@area` | `@bar` | `@barcon` | *`@plot`* | `@plotcmp` |
% `@plotpred` | `@stem` ] - (Inheritable from parent objects) Plot function
% that will be used to create graphs.
%
% * `'plotOptions='` [ cell | *empty* ] - Options passed as the last input
% arguments to the plot function.
%
% * `yAxis='` [ *`'left'`* | *`'right'` ] - Choose the LHS or RHS axis to
% plot this series; see also comments on LHS-RHS plots in Description.
%
% Generic options
% ================
%
% See help on [generic options](report/Contents) in report objects.
%
% Description
% ============
%
% Using the options `'nan='`, `'inf='`, `'pureZero='` and `'printedZero='`
% -------------------------------------------------------------------------
%
% When specifying the LaTeX string for these options, bear in mind that the
% table entries are printed in the math model. This means that whenever you
% wish to print a normal text, you need to use an appropriate text
% formatting command allowed within a math mode. Most frequently, it would
% be `'\textnormal{...}'`.
%
% Using the option `'plotFunc='`
% -------------------------------
%
% When you set the option to `'plotpred'`, the input data `X` (second input
% argument) must be a multicolumn tseries object where the first column is
% the time series observations, and the second and further columns are its
% Kalman filter predictions as returned by the `filter` function.
%
% Conditional formatting
% -----------------------
%
% The conditional format struct (or an array of structs) specified through
% the `'condFormat='` option must have two fields, `.test` and `.format`.
%
% The `.test` field is a text string with a Matlab expression. The
% expression must evaluate to a scalar true or false, and can refer to the
% following attributes associated with each entry in the data part of the
% table:
%
% * `value` - the numerical value of the entry,
% * `date` - the date under which the entry appears,
% * `year` - the year under which the entry appears,
% * `period` - the period within the year (e.g. month or quarter) under
% which the entry appears,
% * `freq` - the frequency of the date under which the entry appears,
% * `text` - the text label on the left,
% * `mark` - the text mark on the left used to describe the individual rows
% reported for multivariate series,
% * `row` - the row number within a multivariate series.
% * `rowvalues` - a row vector of all values on the current row.
%
% If the table is based on user-defined structure of columns (option
% `'colstruct='` in [`table`](report/table)), the following additional
% attributes are available
%
% * `colname` - descriptor of the column (text in the headline).
%
% You can combine a number of attribues within one test, using the logical
% operators, e.g.
%
%     'value > 0 && year > 2010'
%
% The `.format` fields of the conditional format structure consist of LaTeX
% commands that will be use to typeset the corresponding entry. The
% reference to the entry itself is through a question mark. The entries are
% typeset in math mode; this for instance meanse that for bold or italic
% typface, you must use the `\mathbf{...}` and `\mathit{...}` commands.
%
% In addition to standard LaTeX commands, you can use the following
% IRIS-specific commands in the format strings:
%
% * `\sprintf{FFFF}` - to modify the way each numeric entry that passes the
% test is printed by the `sprintf` function; `FFFF` is one of the standard
% `sprintf` formatting strings.
%
% * `\hide{?}` - to hide the actual entry when it is supposed to be
% replaced with something else.
%
% You can combine multiple tests and their correponding formats in one
% structure; they will be all applied to each entry in the specified order.
%
% LHS-RHS plots
% --------------
%
% The LHS-RHS report graphs are still an experimental feature.
%
% When the option `'yAxis='` is used to plot on both the LHS and the RHS
% y-axis, the plot functions are restricted to `@plot`, `@bar`, `@area` and
% `@stem`. Also, because of a bug in Matlab, always control the color of
% the lines, bars and areas in all LHS-RHS graphs: use either the option
% `'plotOptions='` in this command, or `'style='` in the respective
% [`graph`](report/graph) command.
%
% Example (Conditional format structure)
% =======================================
%
% Typeset negative values in italic, and values in periods before 2010Q1
% blue:
%
%     cf = struct( );
%     cf(1).test = 'value < 0';
%     cf(1).format = '\mathit{?}';
%     cf(2).test = 'date < qq(2010,1)';
%     cf(2).format = '\color{blue}';
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
