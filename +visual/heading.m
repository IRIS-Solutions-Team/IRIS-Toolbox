function textHandles = heading(varargin)
% heading  Print heading at the top of graphics figure

textHandles = gobjects(0, 1);

if nargin==0
    return
end

if nargin==1 && all(isgraphics(varargin{1}))
    return
end

if all(isgraphics(varargin{1}))
    varargin = [varargin(2), {'Figure'}, varargin(1), varargin(3:end)];
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('visual.heading');
    pp.KeepUnmatched = true;
    addRequired(pp, 'String', @(x) ischar(x) || isstring(x) || iscellstr(x));
    addParameter(pp, 'Figure', gobjects(0), @(x) all(isgraphics(x)));
end
%)
parse(pp, varargin{:});
string = pp.Results.String;
handleFigure = pp.Results.Figure;
unmatched = pp.UnmatchedInCell;

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
    textHandles = [ 
        textHandles
        printHeading(handleFigure(i), string, unmatched{:}) 
    ]; %#ok<AGROW>
end

end%


%
% Local Functions
%


function textHandles = printHeading(handleFigure, string, varargin)
    %(
    figureFontSize = get(handleFigure, 'DefaultAxesFontSize');
    fontSize = 1.3*figureFontSize;
    textHandles = annotation( ...
        handleFigure, ...
        'TextBox', [0, 1, 1, 0], ...
        'FontSize', fontSize, ...
        'String', string, ...
        'Horizontal', 'Center', ...
        'Vertical', 'Top', ...
        'LineStyle', 'None', ...
        varargin{:} ...
    );
    %)
end%

