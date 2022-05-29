function colorOrderIndex(axesHandle, action, number)
% colorOrderIndex  Change color order index in Axes

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('visual.colorOrderIndex');
    INPUT_PARSER.addRequired('AxesHandle', @(x) all(isgraphics(x, 'Axes')));
    INPUT_PARSER.addRequired('Action', @(x) any(strcmpi(x, {'=', '+', '-'})));
    INPUT_PARSER.addRequired('Number', @(x) isnumeric(x) && isscalar(x) && x==round(x));
end
INPUT_PARSER.parse(axesHandle, action, number);

%--------------------------------------------------------------------------

currentIndex = get(axesHandle, 'ColorOrderIndex');
switch action
    case '='
        newIndex = number;
    case '+'
        newIndex = currentIndex + number;
    case '-'
        newIndex = currentIndex - number;
end
set(axesHandle, 'ColorOrderIndex', newIndex);

end
