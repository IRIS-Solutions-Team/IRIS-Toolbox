function clicktocopy(ax)
% clicktocopy  Axes will expand in a new window when clicked on.
%
% Syntax
% =======
%
%     grfun.clicktocopy(h)
%
%
% Input arguments
% ================
%
% * `h` [ numeric ] - Handle to axes objects that will be added a Button
% Down callback opening them in a new window on mouse click.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('h', @(x) all(ishghandle(x)) ...
    && all(strcmp(get(x, 'type'), 'axes')));

%--------------------------------------------------------------------------

set(ax, 'buttonDownFcn', @copyAxes);
h = findobj(ax, 'tag', 'highlight');
set(h, 'buttonDownFcn', @copyAxes);
h = findobj(ax, 'tag', 'vline');
set(h, 'buttonDownFcn', @copyAxes);

end




function copyAxes(h, varargin)
POSITION = [0.1300, 0.1100, 0.7750, 0.8150];
if ~all(strcmpi(get(h, 'type'), 'axes'))
    h = get(h, 'parent');
end
new = copyobj(h, figure( ));
set(new, ...
    'position', POSITION, ...
    'units', 'normalized', ...
    'buttonDownFcn', '');
end
