% array  Insert array with user data.
%
% Syntax
% =======
%
%     P.array(Caption,Data)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Caption` [ char | cellstr ] - Title or a cell array with title and
% subtitle displayed at the top of the array; see Description for splitting
% the title or subtitle into multiple lines.
%
% * `Data` [ cell ] - Cell array with input data; numeric and text entries
% are allowed.
%
% Options
% ========
%
% * `'arrayStretch='` [ numeric | *`1.15`* ] - (Inherited) Stretch between
% lines in the array (in pts).
%
% * `'captionTypeface='` [ cellstr | char | *`'\large\bfseries'`* ] -
% (Inherited) \LaTeX\ format commands for typesetting the array caption;
% the subcaption format can be entered as the second cell in a cell array.
%
% * `'colWidth='` [ numeric | *`NaN`* ] - (Inheritable from parent objects)
% Width, or a vector of widhts, of the array columns in `em `units; `NaN`
% means the width of the column will adjust automatically.
%
% * `'format='` [ char | *`'%.2f'`* ] - (Inherited) Numeric format string;
% see help on the built-in `sprintf` function.
%
% * `'footnote='` [ char | *empty* ] - (Inherited) Footnote at the array
% title; only shows if the title is non-empty.
%
% * `'heading='` [ char | cellstr | *empty* ] - (Inherited) User-supplied
% heading, i.e. an extra row or rows at the top of the array. The heading
% can be either a \LaTeX\ code, or a cell array whose size is consistent
% with `Data`. The heading is repeated at the top of each new page when
% used with `'long=' true`.
%
% * `'inf='` [ char | *`'$\infty$'`* ] - (Inherited) \LaTeX\ string that
% will be used to typeset `Inf`s.
%
% * `'long='` [ `true` | *`false`* ] -  (Inherited) If `true`, the array
% may stretch over more than one page.
%
% * `'longFoot='` [ char | *empty* ] - (Inherited) Footnote that appears at
% the bottom of the array (if it is longer than one page) on each page
% except the last one; works only with `'long='` `true`.
%
% * `'longFootPosition='` [ `'centre'` | *`'left'`* | `'right'` ] -
% (Inherited) Horizontal alignment of the footnote in long arrays; works
% only with `'long='` `true`.
%
% * `'nan='` [ char | *`'$\cdots$'`* ] - (Inherited) \LaTeX\ string that
% will be used to typeset `NaN`s.
%
% * `'pureZero='` [ char | *empty* ] - (Inherited) \LaTeX\ string that will
% be used to typeset pure zero entries; if empty the zeros will be printed
% using the current numeric format.
%
% * `'printedZero='` [ char | *empty* ] - (Inherited) \LaTeX\ string that
% will be used to typeset the entries that would appear as zero under the
% current numeric format used; if empty these numbers will be printed using
% the current numeric format.
%
% * `'separator='` [ char | *`'\medskip\par'`* ] - (Inherited) \LaTeX\
% commands that will be inserted after the array.
%
% * `'sideways='` [ `true` | *`false`* ] - (Inherited) Print the array
% rotated by 90 degrees.
%
% * `'tabcolsep='` [ `NaN` | numeric ] - (Inherited) Space between columns
% in the array, measured in em units; `NaN` means the \LaTeX\ default.
%
% * `'typeface='` [ char | *empty* ] - (Not inherited) \LaTeX\ code
% specifying the typeface for the array as a whole; it must use the
% declarative forms (such as `\itshape`) and not the command forms (such as
% `\textit{...}`).
%
% Generic options
% ================
%
% See help on [generic options](report/Contents) in report objects.
%
% Description
% ============
%
% The input cell array `Data` can contain either strings or numeric values,
% or horizontal rules. Numeric values are printed using the standard
% `sprintf` function and formatted using the `'format='` option. Horizontal
% rules must be entered as a string of five (or more) dashes, `'-----'`, in
% the first cell of the respective row, with all other cells empty in that
% row. If you wish to include a \LaTeX\ command or a piece of \LaTeX\ code,
% you must enclose it in curly brackets.
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
% These commands create a table with two rows separated by a horizontal
% rule, and three columns in each of them. The middle columns will have
% Greek letters printed in \LaTeX\ math mode.
%
%     x = report.new( );
% 
%     A = { ...
%         'First row','{$\alpha$}',10000; ...
%         '-----','',''; ...
%         'Second row','{$\beta$}',20000; ...
%     };
% 
%     x.array('My Table',A);
% 
%     x.publish('test1.pdf');
% 
%     open test1.pdf;
%
% Example
% ========
%
% Use the option `'inputFormat='` to change the way the input strings are
% interpreted. Compare the two tables in the resulting PDF.
%
%     x = report.new( );
% 
%     A = { ...
%         1,2,3; ...
%         '$\alpha$','b','c', ...
%         };
% 
%     x.array('Table with Plain Input Format (Default)',A, ...
%         'heading=',{'A','B','$\Gamma$';'-----','',''});
% 
%     x.array('Table with LaTeX Input Format',A, ...
%         'heading=',{'A','B','$\Gamma$';'-----','',''}, ...
%         'inputFormat=','latex');
% 
%     x.publish('test2.pdf');
% 
%     open test2.pdf;
%


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
