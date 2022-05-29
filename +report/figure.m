% figure  Start new figure
%
% Syntax
% =======
%
%     P.figure(Caption,...)
%
% Syntax to capture an existing figure window
% ============================================
% This is an obsolete syntax, and will be removed from IRIS in a future
% release. Use [`report/userfigure`](report/userfigure) instead.
%
%     P.figure(Caption,H,...)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Caption` [ char | cellstr ] - Title or a cell array with title and
% subtitle displayed at the top of the figure; see Description for
% splitting the title or subtitle into multiple lines.
%
% * `H` [ numeric ] - See help on [`report/userfigure`](report/userfigure).
%
% Options
% ========
%
% * `'aspectRatio='` [ `@auto` | numeric ] - Plot box aspect ratio for all
% graphs in the figure; must be a 1-by-2 vector describing the 
% horizontal-to-vertical ratio.
%
% * `'captionTypeface='` [ cellstr | char | *`'\large\bfseries'`* ] - LaTeX
% format commands for typesetting the figure caption; the subcaption format
% can be entered as the second cell in a cell array.
%
% * `'close='` [ *`true`* | `false` ] - (Inheritable from parent objects)
% Close the underlying figure window when finished; see Description.
%
% * `'separator='` [ char | *`'\medskip\par'`* ] - (Inheritable from parent
% objects) LaTeX commands that will be inserted after the figure.
%
% * `'figureOpt='` [ cell | *empty* ] - Figure options that will be applied
% to the figure handle at opening.
%
% * `'figureScale='` [ numeric | *`0.85`* ] - (Inheritable from parent objects)
% Scale of the figure in the LaTeX document.
%
% * `'figureTrim='` [ numeric | *`0`* ] - Trim figure when it is inserted
% into the report by the specified amount of points; must be either a
% scalar or a 1-by-4 vector (points removed from left, bottom, right, top).
%
% * `'footnote='` [ char | *empty* ] - Footnote at the figure title; only
% shows if the title is non-empty.
%
% * `'sideways='` [ `true` | *`false`* ] - (Inheritable from parent objects)
% Print the table rotated by 90 degrees.
%
% * `'style='` [ struct | *empty* ] - Apply this cascading style structure
% to the figure; see [`grfun.style`](grfun/style).
%
% * `'subplot='` [ numeric | *`'auto'`* ] - (Inheritable from parent objects)
% Subplot division of the figure.
%
% * `'typeface='` [ char | *empty* ] - (Not inheritable from parent objects)
% LaTeX code specifying the typeface for the figure as a whole; it must use
% the declarative forms (such as `\itshape`) and not the command forms
% (such as `\textit{...}`).
%
% * `'visible='` [ `true` | *`false`* ] - (Inheritable from parent objects)
% Visibility of the underlying Matlab figure window.
%
% Generic options
% ================
%
% See help on [generic options](report/Contents) in report objects.
%
% Description
% ============
%
% Figures are top-level report objects and cannot be nested within other
% report objects, except [`align`](report/align). Figure objects can have
% the following types of children:
%
% * [`graph`](report/graph);
% * [`empty`](report/empty).
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
% Figure handle
% --------------
%
% If the option `'close='` is set to `false` the figure window will remain
% open after the report is published. The handle to this figure window will
% be included in the field `.figureHandle` of the information struct `Info`
% returned by [`report/publish`](report/publish).
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
