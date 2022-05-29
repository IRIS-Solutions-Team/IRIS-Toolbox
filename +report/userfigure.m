% userfigure  Insert existing figure window.
%
% Syntax
% =======
%
%     P.userfigure(Caption,H,...)
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
% * `H` [ numeric ] - Handle to a graphics figure created by the user that
% will be captured and inserted in the report.
%
% Options
% ========
%
% See help on [`report/figure`](report/figure) for options available.
%
% Generic options
% ================
%
% See help on [generic options](report/Contents) in report objects.
%
% Description
% ============
%
% The function `report/userfigure` inserts an existing figure window
% (created by the user by standard Matlab commands, and referenced by its
% handle, `H`) into a report:
%
% * The figure and the graphs in it must be created *before* you call
% `report/figure`: any changes or additions to the figure or its graphs
% made after you call the function will not show in the report.
%
% * The userfigure cannot have any children; in other words, you
% cannot call [`report/graph` ](report/graph) after a call to
% `report/userfigure`.
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
% Figure window and figure handle
% --------------------------------
%
% The figure `H` is saved to a `fig` file and stored within the report
% object. At the time of publishing the report, the figure is re-created
% again in a new separate window.
%
% If the option `'close='` is set to `false` this new  figure window will
% remain open after the report is published. The handle to this figure
% window will be included in the field `.figureHandle` of the information
% struct `Info` returned by [`report/publish`](report/publish).
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
