function clicktocopy(axesHandles)
% clickToExpand  Axes will expand in a new window when clicked on.
%
% __Syntax__
%
%     visual.clickToExpand(AxesHandles)
%
%
% __Input Arguments__
%
% * `AxesHandles` [ numeric ] - Handle to axes objects that will be added a
% Button Down callback opening them in a new window on mouse click.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('visual.clickToExpand');
    INPUT_PARSER.addRequired('AxesHandles', @(x) isa(x, 'matlab.graphics.axis.Axes'));
end
INPUT_PARSER.parse(axesHandles);

%--------------------------------------------------------------------------

set(axesHandles, 'ButtonDownFcn', @copyAxes);
h = findobj(axesHandles, 'Tag', 'highlight');
set(h, 'ButtonDownFcn', @copyAxes);
h = findobj(axesHandles, 'Tag', 'vline');
set(h, 'ButtonDownFcn', @copyAxes);

end


function copyAxes(h, varargin)
    POSITION = [0.1300, 0.1100, 0.7750, 0.8150];
    if ~isequal(get(h, 'type'), 'axes')
        h = get(h, 'parent');
    end
    new = copyobj(h, figure( ));
    set(new, ...
        'Position', POSITION, ...
        'Units', 'normalized', ...
        'ButtonDownFcn', '' ...
    );
end
