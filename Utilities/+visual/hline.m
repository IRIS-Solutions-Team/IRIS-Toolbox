function lineHandles = hline(varargin)
% hline  Add horizontal line at specified position to graph(s)
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     LineHandle = visual.hline(~AxesHandle, Location, ...)
%
%
% __Input Arguments__
%
% * `~AxesHandle` [ Axes ] - Handle to an axes object (graph) or to a
% figure window in which the the horizontal line will be added; if omitted
% the line will be added to the current axes.
%
% * `HandleVisibility=false` [ `true` | `false` ] - Visibility of the
% handle to the line and text (caption)  object(s) created.
%
% * `'Location`' [ numeric ] - Vertical position or vector of positions at
% which the horizontal line(s) will be drawn.
%
%
% __Output Arguments__
%
% * `LineHandle` [ Line ] - Handle to the line plotted.
%
%
% __Options__
%
% * `ExcludeFromLegend=true` [ `true` | `false` ] - Exclude the line from
% legend.
%
% Any options valid for the standard `plot` function.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

lineHandles = visual.backend.plotInfiniteLine('hline', varargin{:});

end%

