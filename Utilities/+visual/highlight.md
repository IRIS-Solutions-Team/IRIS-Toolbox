% highlight  Highlight specified range or date range in a graph
%
% __Syntax__
%
%     [patchHandles, textHandles] = highlight(Range, ...)
%     [patchHandles, textHandles] = highlight(AxesHandles, Range, ...)
%
%
% __Input Arguments__
%
% * `Range` [ numeric ] - X-axis range or date range that will be
% highlighted.
%
% * `AxesHandles` [ numeric ] - Handle(s) to axes object(s) in which the
% highlight will be made.
%
%
% __Output Arguments__
%
% * `PatchHandles` [ numeric ] - Handle to the highlighted area (patch object).
%
% * `TextHandles` [ numeric ] - Handle to the caption (text object).
%
%
% __Options__
%
% * `Text=''` [ cellstr | char | string ] - Annotate the highlighted area
% with a text string.
%
% * `Color=0.8` [ numeric | char ] - An RGB color code, a Matlab color
% name, or a scalar shade of gray.
%
% * `ExcludeFromLegend=true` [ `true` | `false` ] - Exclude the highlighted
% area from legend.
%
% * `HandleVisibility=false` [ `true` | `false` ] - Visibility of the
% handle to the patch object(s) created.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team
