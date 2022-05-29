% band  Add new data with lower and upper bounds to graph or table.
%
%
% Syntax
% =======
%
%     P.band(Caption,X,Low,High,...)
%
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Caption` [ char ] - Caption used as a default legend entry in a graph,
% or in the leading column in a table.
%
% * `X` [ tseries ] - Input data with the centre of the band.
%
% * `Low` [ tseries ] - Input data with lower bounds; can be specified
% either relative to the centre or absolute, see the option `'relative='`.
%
% * `High` [ tseries ] - Input data with upper bounds; can be specified
% either relative to the centre or absolute, see the option `'relative='`.
%
%
% Generic options
% ================
%
% See help on [generic options](report/Contents) in report objects.
%
%
% Options for table and graph bands
% ==================================
%
% * `'excludeFromLegend='` [ *`true`* | `false` ] - Exclude bands around
% central lines from legend.
%
% * `'high='` [ char | *'High'* ] - (Inheritable from parent objects) Mark
% used to denote the upper bound.
%
% * `'low='` [ char | *'Low'* ] - (Inheritable from parent objects) Mark
% used to denote the lower bound.
%
% * `'relative='` [ *`true`* | `false` ] - (Inheritable from parent objects) If
% true, the data for the lower and upper bounds are relative to the centre,
% i.e. the bounds will be added to the centre (in this case, `LOW` must be
% negative numbers and `HIGH` must be positive numbers). If false, the
% bounds are absolute data (in this case `LOW` must be lower than `X`, and
% `HIGH` must be higher than `X`).
%
%
% Options for table bands
% ========================
%
% * `'bandTypeface='` [ char | *`'\footnotesize'`* ] - (Inheritable from parent
% objects) LaTeX format string used to typeset the lower and upper bounds.%
%
%
% Options for graph bands
% ========================
%
% * `'plotType='` [ `'errorbar'` | *`'patch'`* ] - Type of plot used to draw
% the band.
%
% * `'relative='` [ *`true`* | `false` ] - (Inheritable from parent objects) If
% true the lower and upper bounds will be, respectively, subtracted from
% and added to to the middle line.
%
% * `'white='` [ numeric | *`0.85`* ] - (Inheritable from parent objects)
% Proportion of white colour mixed with the center line color and used to
% fill the band area.
%
% See help on [`report/series`](report/series) for other options available.
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
