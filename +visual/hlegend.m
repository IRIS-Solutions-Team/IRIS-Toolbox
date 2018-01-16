function legendHandle = hlegend(location, varargin)
% hlegend  Horizontal legend displayed at top or bottom of figure window
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     Legend = visual.hlegend(Location, ...)
%
%
% __Input Arguments__
%
% * `Location` [ `'top'` | `'bottom'` ] - Location of the legend within the
% figure window.
%
% All other input arguments are the same as input arguments into the
% standard Matlab function `legend( )`.
%
%
% __Output Arguments__
%
% * `Legend` [ numeric ] - Handle to legend objects created.
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('visual.legend');
    INPUT_PARSER.addRequired('Location', @(x) any(strcmpi(x, {'Top', 'Bottom'})));
end
INPUT_PARSER.parse(location);

MARGIN = 0.01;

%--------------------------------------------------------------------------

% When called with Axes handles, allow for Figure handles as well, and
% extract the current Axes from each Figure.
if ~isempty(varargin) && all(isgraphics(varargin{1}, 'Axes') | isgraphics(varargin{1}, 'Figure'))
    varargin{1} = visual.backend.resolveAxesHandles('Current', varargin{1});
end

legendHandle = legend(varargin{:});

if ~isempty(legendHandle)
    set(legendHandle, 'Orientation', 'Horizontal');
    for i = 1 : numel(legendHandle)
        moveLegend(legendHandle(i), location, MARGIN);
    end
end

end


function moveLegend(legendHandle, location, margin)
    parentFigureHandle = get(legendHandle, 'Parent');
    set(parentFigureHandle, 'Units', 'Normalized');
    oldPosition = get(legendHandle, 'Position');
    newPosition = oldPosition;
    newPosition(1) = 0.5 - oldPosition(3)/2;
    if strcmpi(location, 'bottom')
        newPosition(2) = margin;
    elseif strcmpi(location, 'top')
        newPosition(2) = (1 - margin) - oldPosition(4);
    end
    drawnow( );
    set(legendHandle, 'Position', newPosition);
end

