% vline  Add vertical line to graph.
%
% Syntax
% =======
%
%     P.vline(Caption,Date,...)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Caption` [ char ] - Caption used to annotate the vertical line.
%
% * `Date` [ numeric ] - Date at which the vertical line will be plotted.
%
% Options
% ========
%
% * `'hPosition='` [ `'bottom'` | `'middle'` | *`'top'`* ] - (Inheritable from
% parent objects) Horizontal position of the caption.
%
% * `'vPosition='` [ `'centre'` | `'left'` | *`'right'`* ] - (Inheritable from
% parent objects) Vertical position of the caption relative to the line.
%
% * `'timePosition='` [ `'after'` | `'before'` | `'middle'` ] - Placement of the
% vertical line on the time axis: in the middle of the specified period,
% immediately before it (between the specified period and the previous
% one), or immediately after it (between the specified period and the next
% one).
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
