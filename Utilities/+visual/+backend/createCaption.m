function captionHandle = createCaption(axesHandle, location, varargin)
% createCaption  Place text caption at the edge of an annotating object
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('visual.backend.createCaption');
    parser.KeepUnmatched = true;
    parser.addRequired('AxesHandles', @(x) all(isgraphics(x, 'Axes')) && isscalar(x));
    parser.addRequired('Location', @(x) isnumeric(x) || isa(x, 'DateWrapper') || isa(x, 'datetime'));
    parser.addParameter('String', @validate.string);
    parser.addParameter('HorizontalPosition', 'right', @(x) validate.anyString(x, 'center', 'centre', 'middle', 'left', 'right'));
    parser.addParameter('VerticalPosition', 'top', @(x) validate.numericScalar(x) || validate.anyString(x, 'center', 'centre', 'middle', 'top', 'bottom'));
end
parse(parser, axesHandle, location, varargin{:});
opt = parser.Options;
unmatched = parser.UnmatchedInCell;

%--------------------------------------------------------------------------

% Horizontal position and alignment
inside = length(location)>1;
if strcmpi(opt.HorizontalPosition, 'Left')
    if inside
        horizontalAlignment = 'left';
    else
        horizontalAlignment = 'right';
    end
    x = location(1);
elseif strcmpi(opt.HorizontalPosition, 'Right')
    if inside
        horizontalAlignment = 'right';
    else
        horizontalAlignment = 'left';
    end
    x = location(end);
else
    horizontalAlignment = 'center';
    x = location(1) + (location(end) - location(1))/2;
end

% Vertical position and alignment
yLim = get(axesHandle, 'YLim');
ySpan = yLim(end) - yLim(1);
if strcmpi(opt.VerticalPosition, 'Top')
    y = 0.98;
    verticalAlignment = 'top';
elseif strcmpi(opt.VerticalPosition, 'Bottom')
    y = 0.02;
    verticalAlignment = 'bottom';
elseif any(strcmpi(opt.VerticalPosition, {'Centre', 'Center', 'Middle'}))
    y = 0.5;
    verticalAlignment = 'middle';
else
    y = opt.VerticalPosition;
    verticalAlignment = 'middle';
end

captionHandle = text( x, yLim(1)+y*ySpan, opt.String, ...
                     'Parent', axesHandle, ...
                     'Color', [0, 0, 0], ...
                     'VerticalAlignment', verticalAlignment, ...
                     'HorizontalAlignment', horizontalAlignment, ...
                     unmatched{:} );

end%

