function lineHandles = zeroline(varargin)
% zeroline  Add horizontal zero line to graph(s)
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     LineHandle = visual.zeroline(~AxesHandle, ...)
%
%
% __Input Arguments__
%
% * `~AxesHandle` [ Axes ] - Handle to an axes object (graph) or to a
% figure window in which the the horizontal line will be added; if omitted
% the line will be added to the current axes.
%
%
% __Output Arguments__
%
% * `LineHandle` [ Line ] - Handle to the line plotted.
%
%
% __Options__
%
% * `'ExcludeFromLegend='` [ *`true`* | `false` ] - Exclude the line from
% legend.
%
% * `HandleVisibility=false` [ `true` | `false` ] - Visibility of the
% handle to the line and text (caption)  object(s) created.
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

lineHandles = visual.backend.plotInfiniteLine('zeroline', varargin{:});

end%

