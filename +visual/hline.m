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
% * `'ExcludeFromLegend='` [ *`true`* | `false` ] - Exclude the line from
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~isempty(varargin) && all(ishghandle(varargin{1}))
    axesHandles = varargin{1};
    varargin(1) = [ ];
else
    axesHandles = gca( );
end

lineHandles = ...
    visual.backend.plotInfiniteLine(axesHandles, 'horizontal', varargin{:});

end
