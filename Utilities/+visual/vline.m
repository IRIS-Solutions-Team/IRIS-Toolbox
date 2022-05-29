function [lineHandles, textHandles] = vline(varargin)
% vline  Add vertical line with text caption at the specified position to graph(s)
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [LineHandle, TextHandle] = grfun.vline(~AxesHandles, Location, ...)
%
%
% __Input Arguments__
%
% * `Location` [ numeric ] - Horizontal position or vector of positions at
% which the vertical line(s) will be drawn.
%
% * `~AxesHandles` [ numeric ] - Handle(s) to axes objects (graphs) or to
% figure windowsin which the the line will be added; if omitted the
% line will be added to the current axes.
%
%
% __Output Arguments__
%
% * `LineHandle` [ Line ] - Handle(s) to the vline(s) plotted (line objects).
%
% * `TextHandle` [ Text ] - Handle(s) to the caption(s) created (text
% objects).
%
%
% __Options__
%
% * `ExcludeFromLegend=true` [ `true` | `false` ] - Exclude vline from
% legend.
%
% * `HandleVisibility=false` [ `true` | `false` ] - Visibility of the
% handle to the line and text (caption)  object(s) created.
%
% * `Placement='Exactly'` [ `'Exactly'` | `'Before'` | `'After'` ] -
% Placement of the vertical line relative to the specified date;
% `'Exactly'` means the line is at the date specified, `'Before'` means the
% line is half way between the date specified and the date preceeding it,
% `'After'` means the line is half way between the date specified and the
% date follwing it.
%
% * `Text=''` [ cellstr | char | string ] - Annotate vline with a text
% string.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

[lineHandles, textHandles] = visual.backend.plotInfiniteLine('vline', varargin{:});

end%

