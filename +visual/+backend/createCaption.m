function captionHandle = createCaption(axesHandle, location, varargin)
% createCaption  Place text caption at the edge of an annotating object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('visual.backend.createCaption');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('AxesHandles', @(x) all(isgraphics(x, 'Axes')) && isscalar(x));
    inputParser.addRequired('Location', @(x) isnumeric(x) || isa(x, 'DateWrapper') || isa(x, 'datetime'));
    inputParser.addParameter('String', @(x) ischar(x) || iscellstr(x) || isstring(x));
    inputParser.addParameter('HorizontalPosition', 'right', @(x) any(strcmpi(x, {'center', 'centre', 'middle', 'left', 'right'})));
    inputParser.addParameter('VerticalPosition', 'top', @(x) any(strcmpi(x, {'center', 'centre', 'middle', 'top', 'bottom'})));
end
inputParser.parse(axesHandle, location, varargin{:});
opt = inputParser.Options;
unmatched = inputParser.UnmatchedInCell;

%--------------------------------------------------------------------------

% Horizontal position and alignment.
inside = length(location)>1;
switch lower(opt.HorizontalPosition)
   case 'left'
      if inside
         horizontalAlignment = 'left';
      else
         horizontalAlignment = 'right';
      end
      x = location(1);
   case 'right'
      if inside
         horizontalAlignment = 'right';
      else
         horizontalAlignment = 'left';
      end
      x = location(end);
   otherwise
      horizontalAlignment = 'center';
      x = location(1) + (location(end) - location(1))/2;
end

% Vertical position and alignment.
yLim = get(axesHandle, 'YLim');
ySpan = yLim(end) - yLim(1);
switch lower(opt.VerticalPosition)
   case 'top'
      y = 0.98;
      verticalAlignment = 'top';
   case 'bottom'
      y = 0.02;
      verticalAlignment = 'bottom';
   case {'centre', 'center', 'middle'}
      y = 0.5;
      verticalAlignment = 'middle';
   otherwise
      y = opt.VerticalPosition;
      verticalAlignment = 'middle';
end

captionHandle = text( ...
    x, yLim(1)+y*ySpan, opt.String, ...
   'Parent', axesHandle, ...
   'Color', [0, 0, 0], ...
   'VerticalAlignment', verticalAlignment, ...
   'HorizontalAlignment', horizontalAlignment, ...
   unmatched{:} ...
);

end
