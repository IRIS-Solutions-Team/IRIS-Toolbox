function legendHandle = hlegend(location, varargin)
% hlegend  Horizontal legend displayed at top or bottom of figure window
%{
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     legendHandle = visual.hlegend(location, ...)
%
%
% __Input Arguments__
%
% * `location` [ `'Top'` | `'Bottom'` ] - Location of the legend within the
% figure window.
%
% All other input arguments are the same as input arguments into the
% standard Matlab function `legend( )`.
%
%
% __Output Arguments__
%
% * `legendHandle` [ numeric ] - Handle to legend objects created.
%
%
% __Options__
%
% See help on the standard Matlab function  `legend( )` for the options
% available.
%
%
% __Description__
%
%
% __Example__
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('visual.hlegend');
    parser.addRequired('Location', @(x) any(strcmpi(x, {'Top', 'Bottom'})));
end
parser.parse(location);

MARGIN = 0.01;

%--------------------------------------------------------------------------

% When called with Axes handles, allow for Figure handles as well, and
% extract the current Axes from each Figure.
axesHandle = {};
if ~isempty(varargin) && all(isgraphics(varargin{1}, 'Axes') | isgraphics(varargin{1}, 'Figure'))
    axesHandle = varargin(1);
    varargin(1) = [];
    axesHandle{1} = visual.backend.resolveAxesHandles('Current', axesHandle{1});
end

legendHandle = legend(axesHandle{:}, varargin{:});

if ~isempty(legendHandle)
    set(legendHandle, 'Orientation', 'Horizontal');
    currentAxesHandle = visual.backend.getCurrentAxesIfExists( );
    if ~isempty(currentAxesHandle)
        currentFigureHandle = get(currentAxesHandle, 'Parent');
        setappdata(currentFigureHandle, 'IRIS_OutsideLegend', [{location}, varargin]);
    end
    for i = 1 : numel(legendHandle)
        moveLegend(legendHandle(i), location, MARGIN);
    end
end

end%


%
% Local Functions
%


function moveLegend(legendHandle, location, margin)
    parentHandle = get(legendHandle, 'Parent');
    type = get(parentHandle, 'Type');
    while ~strcmpi(type, 'figure')
        parentHandle = get(parentHandle, 'Parent');
        type = get(parentHandle, 'Type');
    end
    set(parentHandle, 'Units', 'Normalized');
    oldPosition = get(legendHandle, 'Position');
    newPosition = oldPosition;
    newPosition(1) = 0.5 - oldPosition(3)/2;
    if strcmpi(location, 'bottom')
        newPosition(2) = margin;
    elseif strcmpi(location, 'top')
        newPosition(2) = (1 - margin) - oldPosition(4);
    end
    set(legendHandle, 'Position', newPosition);
end%

