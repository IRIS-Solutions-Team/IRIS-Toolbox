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

if ~isempty(varargin) 
    if isequal(varargin{1}, false)
        return
    elseif isequal(varargin{1}, true)
        varargin(1) = [ ];
    end
end

lineHandles = ...
    visual.backend.plotInfiniteLine(axesHandles, 'horizontal', 0, varargin{:});

set(lineHandles, 'tag', 'zeroline');

end
