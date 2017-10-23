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
% * `'ExcludeFromLegend='` [ *`true`* | `false` ] - Exclude vline from
% legend.
%
% * `'LinePlacement='` [ *`'exactly'`* | `'before'` | `'after'` ] -
% Placement of the vertical line relative to the specified date; `'exactly'`
% means the line is at the date specified, `'before'` means the line is
% half way between the date specified and the date preceeding it, `'after'`
% means the line is half way between the date specified and the date
% follwing it.
%
% * `'Text='` [ cellstr | char | string ] - Annotate vline with a text
% string.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~isempty(varargin) && all(ishghandle(varargin{1}))
    axesHandles = varargin{1};
    varargin(1) = [ ];
else
    axesHandles = gca( );
end

[lineHandles, textHandles] = ...
    visual.backend.plotInfiniteLine(axesHandles, 'vertical', varargin{:});

end
