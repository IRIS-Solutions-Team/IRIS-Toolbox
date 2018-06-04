function handleText = header(varargin)

handleText = gobjects(0, 1);

if nargin==0
    return
end

if nargin==1 && all(isgraphics(varargin{1}))
    return
end

if all(isgraphics(varargin{1}))
    varargin([1, 2]) = varargin([2, 1]);
end

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('visual.header');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('String', @(x) ischar(x) || isa(x, 'string') || iscellstr(x));
    inputParser.addOptional('HandleFigure', gobjects(0), @(x) all(isgraphics(x)));
end
inputParser.parse(varargin{:});
string = inputParser.Results.String;
handleFigure = inputParser.Results.HandleFigure;
unmatched = inputParser.UnmatchedInCell;

if isempty(string)
    return
end

if isempty(handleFigure)
    handleFigure = visual.backend.getCurrentFigureIfExists( );
    if isempty(handleFigure)
        return
    end
end

%--------------------------------------------------------------------------

for i = 1 : numel(handleFigure)
    handleText = [
        handleText
        printHeader(handleFigure(i), string, unmatched{:})
    ];
end

end%


function handleText = printHeader(handleFigure, string, varargin)
    handleText = annotation( ...
        handleFigure, ...
        'TextBox', [0, 1, 1, 0], ...
        'String', string, ...
        'Horizontal', 'Center', ...
        'Vertical', 'Top', ...
        'LineStyle', 'None', ...
        varargin{:} ...
    );
end%

