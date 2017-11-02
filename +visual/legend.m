function legendHandle = legend(varargin)
% legend  Horizontal legend displayed at top or bottom of figure window
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     Legend = visual.legend(Location, Entry, Entry, ...)
%     Legend = visual.legend(~Axes, Location, Entry, Entry, ...)
%
%
% __Input Arguments__
%
% * `~Axes` [ Axes | Figure ] - Handle(s) to either axes objects or figure
% objects for which bottom legend will be created; if omitted, legend will
% be created for the current axes.
%
% * `Location` [ `'top'` | `'bottom'` ] - Location of the legend within the
% figure window.
%
% * `Entry` [ char | cellstr ] - Legend entries and options; same as in the
% standard `legend` function.
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

axesHandle = @gca;
if all(isgraphics(varargin{1}))
    axesHandle = varargin{1};
    varargin(1) = [ ];
end

location = varargin{1};
varargin(1) = [ ];

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('visual.legend');
    INPUT_PARSER.KeepUnmatched = true;
    INPUT_PARSER.addRequired('Location', @(x) any(strcmpi(x, {'Top', 'Bottom'})));
    INPUT_PARSER.addOptional('AxesHandle', @gca, @(x) isequal(x, @gca) || all(isgraphics(x, 'Axes') | isgraphics(x, 'Figure')));
end
INPUT_PARSER.parse(location, axesHandle);

% Input handles can be either Axes objects or Figure objects. If they are
% Figures, get the current Axes from within each Figure, and create top or
% bottom legend for it.
if isgraphics(axesHandle)
    axesHandle = visual.backend.resolveAxesHandles('Current', axesHandle);
end

MARGIN = 0.01;

%--------------------------------------------------------------------------

if isequal(axesHandle, @gca)
    legendHandle = legend(varargin{:});
else
    legendHandle = gobjects(1, 0);
    for i = 1 : numel(axesHandle)
        legendHandle = [ ...
            legendHandle, ...
            legend(axesHandle(i), varargin{:}) ...
        ];
    end
end

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

