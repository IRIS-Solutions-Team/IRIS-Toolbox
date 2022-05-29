% table  Start new table.
%
% Syntax
% =======
%
%     P.table(Caption,...)
%
% Input arguments
% ================
%
% * `P` [ report ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Caption` [ char | cellstr ] - Title or a cell array with title and
% subtitle displayed at the top of the table; see Description for splitting
% the title or subtitle into multiple lines.
%
% Options
% ========
%
% * `'arrayStretch='` [ numeric | *`1.15`* ] - (Inheritable from parent
% objects) Stretch between lines in the table (in pts).
%
% * `'captionTypeface='` [ cell | *`'\large\bfseries'`* ] - LaTeX format
% commands for typesetting the table caption and subcaption; you can use
% Inf for either to indicate the default format.
%
% * `'colFootnote='` [ cell | *empty* ] - Footnotes for individual dates in
% the headings of the columns, or column names in user-defined tables; the
% option must be a cell array with date-footnote pairs.
%
% * `'colHighlight='` [ numeric | *empty* ] - Dates for which the entire
% corresponding columns will be highlighted; because of a bug in the LaTex
% package `colortbl`, this option cannot be combined with the option
% `'rowHighlight='` in [`report/series`](report/series).
%
% * `'colStruct='` [ struct | *empty* ] - User-defined structure of the
% table columns; use of this option disables `'range='`.
%
% * `'colWidth='` [ numeric | *`NaN`* ] - (Inheritable from parent objects)
% Width, or a vector of widhts, of the table columns in `em `units; `NaN`
% means the width of the column will adjust automatically.
%
% * `'headlineJust='` [ *`'c'`* | `'l'` | `'r'` ] - Horizontal
% justification of the headline entries (individual dates or user-defined
% text): centre, left, right.
%
% * `'footnote='` [ char | *empty* ] - Footnote at the table title; only
% shows if the title is non-empty.
%
% * `'long='` [ true | *`false`* ] - (Inheritable from parent objects) If
% true, the table may stretch over more than one page.
%
% * `'longFoot='` [ char | *empty* ] - (Inheritable from parent objects)
% Works only with `'long='`=true: Footnote that appears at the bottom of
% the table (if it is longer than one page) on each page except the last
% one.
%
% * `'longFootPosition='` [ `'centre'` | *`'left'`* | `'right'` ] -
% (Inheritable from parent objects) Works only with `'long='` `true`:
% Horizontal alignment of the footnote in long tables.
%
% * `'range='` [ numeric | *empty* ] - (Inheritable from parent objects)
% Date range or vector of dates that will appear as columns of the table.
%
% * `'separator='` [ char | *`'\medskip\par'`* ] - (Inheritable from parent
% objects) \LaTeX\ commands that will be inserted after the table.
%
% * `'sideways='` [ `true` | *`false`* ] - (Inheritable from parent objects)
% Print the table rotated by 90 degrees.
%
% * `'tabcolsep='` [ `NaN` | numeric ] - (Inheritable from parent objects)
% Space between columns in the table, measured in em units; NaN means the
% \LaTeX\ default.
%
% * `'typeface='` [ char | *empty* ] - \LaTeX\ code specifying the typeface
% for the table as a whole; it must use the declarative forms (such as
% `\itshape`) and not the command forms (such as `\textit{...}`).
%
% * `'vline='` [ numeric | *empty* ] - (Inheritable from parent objects)
% Vector of dates after which a vertical line (divider) will be placed.
%
% Date format options
% ====================
%
% See [`dat2str`](dates/dat2str) for details on date format options.
%
% * `'dateFormat='` [ char | cellstr | *`'YYYYFP'`* ] - Date format string,
% or array of format strings (possibly different for each date).
%
% * `'months='` [ cellstr | *`{'January',...,'December'}`* ] - Twelve
% strings representing the names of the twelve months.
%
% * `'standinMonth='` [ numeric | `'last'` | *`1`* ] - Month that will
% represent a lower-than-monthly-frequency date if the month is part of the
% date format string.
%
% Generic options
% ================
%
% See help on [generic options](report/Contents) in report objects.
%
% Description
% ============
%
% Tables are top-level report objects and cannot be nested within other
% report objects, except [`align`](report/align). Table objects can have
% the following children:
%
% * [`series`](report/series);
% * [`subheading`](report/subheading).
%
% By default, the date row is printed as a leading row with dates formated
% using the option `'dateFormat='`. Alternatively, you can specify this
% option as a cell array of two strings. In that case, the dates will be
% printed in two rows. The first row will have a date string displayed and
% centred for every year, and the first cell of the `'dateFormat='` option
% will be used for formatting. The second row will have a date displayed
% for every period (i.e. every column), and the second cell of the
% `'dateFormat='` option will be used for formatting.
%
% User-defined structure of the table columns
% --------------------------------------------
%
% Use the option `'colStruct='` to define your own table columns. This
% gives you more flexibility than when using the `'range='` option in
% defining the content of the table.
%
% The option `'colStruct='` must be a 1-by-N struct, where N is the
% number of columns you want in the table, with the following fields:
%
% * `'name='` - specifies the descriptor of the column that will be
% displayed in the headline;
%
% * `'func='` - specifies a function that will be applied to the input
% series; if `'func='` is empty, no function will be applied. The function
% must evaluate to a tseries or a numeric scalar.
%
% * `'date='` - specifies the date at which a number will be taken from the
% series unless the function `'func='` applied before resulted in a numeric
% scalar.
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
% Compare the headers of these two tables:
%
%     x = report.new( );
%
%     x.table('First table', ...
%         'range',qq(2010,1):qq(2012,4), ...
%         'dateformat','YYYYFP');
%     % You can add series or subheadings here.
%
%     x.table('Second table', ...
%         'range,qq(2010,1):qq(2012,4), ...
%         'dateformat',{'YYYY','FP'});
%     % You can add series or subheadings here.
%
%     x.publish('myreport.pdf');
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
