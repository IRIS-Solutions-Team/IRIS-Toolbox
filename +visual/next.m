function varargout = next(varargin)
% next  Simplify use of standard subplot function.
%
% __Syntax for New Figure Window With Certain Subplot Division__
%
%     Fig = visual.next([NumRows, NumColumns], ...)
%     Fig = visual.next(NumRows, NumColumns, ...)
%
%
% __Syntax for New Graph at Next Subplot Position__
%
%     [Axes, Fig, Count]  = visual.next( )
%
%
% __Input Arguments__
%
% * `NumRows` [ numeric ] - Number of rows in which graphs will be
% arranged in the figure window.
%
% * `NumColumns` [ numeric ] - Number of columns in which graphs will
% be arranged in the figure window.
%
%
% __Output Arguments__
%
% * `Fig` [ numeric ] - Handle to the figure window created.
%
% * `Axes` [ numeric ] - Handle to the axes created.
%
% * `Count` [ numeric ] - Count of the subplots created in the current
% figure window including the next one.
%
%
% __Options__
%
% Any options will be passed into the `figure( )` function when opening a
% new figure window.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.


%--------------------------------------------------------------------------

skipOnePosition = ~isempty(varargin) && isequaln(varargin{1}, NaN);

if ~isempty(varargin) && ~skipOnePosition
    % Open a new figure and initialise subplot data.
    varargout = cell(1, 1);
    varargout{1} = initialize(varargin{:});
    return
end

currentFigureHandle = get(0, 'CurrentFigure');
if isempty(currentFigureHandle)
    error('No figure window open, cannot use visual.next( )');
end

numRows = getappdata(currentFigureHandle, 'IRIS_NextNumRows');
numColumns = getappdata(currentFigureHandle, 'IRIS_NextNumColumns');
currentPosition = getappdata(currentFigureHandle, 'IRIS_NextCurrentPosition');

test = @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>=0 && isfinite(x);
assert( ...
    test(numRows) && test(numColumns) && test(currentPosition), ...
    'visual:next:FigureNotConfiguredForNext', ...
    'Current figure window is not configured for visual.next( ).' ...
);

newFigureHandle = [ ];
% Open a new figure if the number of subplots exceeds the maximum.
if currentPosition>=numRows*numColumns
    currentPosition = 0;
    figureProp = getappdata(currentFigureHandle, 'IRIS_NextFigureProperties');
    if isempty(figureProp)
        newFigureHandle = figure( );
    else
        newFigureHandle = figure(figureProp);
    end
    setappdata(newFigureHandle, 'IRIS_NextNumRows', numRows);
    setappdata(newFigureHandle, 'IRIS_NextNumColumns', numColumns);
    setappdata(newFigureHandle, 'IRIS_NextCurrentPosition', currentPosition);
    currentFigureHandle = newFigureHandle;
end

% Add new subplot to the current figure.
currentPosition = currentPosition + 1;
if ~skipOnePosition
    axesHandle = subplot(numRows, numColumns, currentPosition);
    visual.clickToExpand(axesHandle);
    set(axesHandle, 'NextPlot', 'Add', 'Box', 'On');
else
    axesHandle = [ ];
end

setappdata(currentFigureHandle, 'IRIS_NextCurrentPosition', currentPosition);
varargout{1} = axesHandle;
varargout{2} = currentFigureHandle;
varargout{3} = currentPosition;

end


function figureHandle = initialize(varargin)
    persistent INPUT_PARSER
    if isempty(INPUT_PARSER)
        test1 = @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>0;
        test2 = @(x) isnumeric(x) && any(numel(x)==[1, 2]) && all(x==round(x)) && all(x>0);
        INPUT_PARSER = extend.InputParser('visual/next');
        INPUT_PARSER.KeepUnmatched = true;
        INPUT_PARSER.addRequired('NumRows', @(x) test1(x) || test2(x));
        INPUT_PARSER.addOptional('NumColumns', 1, @(x) test1(x));
    end
    INPUT_PARSER.parse(varargin{:});
    numRows = INPUT_PARSER.Results.NumRows;
    numColumns = INPUT_PARSER.Results.NumColumns;
    figureOptions = INPUT_PARSER.Unmatched;

    if any(strcmp(INPUT_PARSER.UsingDefaults, 'NumColumns'))
        if numel(numRows)==1
            % next(totalCount, ...)
            totalCount = numRows;
            [numRows, numColumns] = visual.backend.optimizeSubplot(totalCount);
        else
            % next([numRows, numColumns], ...)
            numColumns = numRows(2);
            numRows = numRows(1);
        end
    end
    figureHandle = figure(figureOptions);
    setappdata(figureHandle, 'IRIS_NextNumRows', numRows);
    setappdata(figureHandle, 'IRIS_NextNumColumns', numColumns);
    setappdata(figureHandle, 'IRIS_NextCurrentPosition', 0);
    setappdata(figureHandle, 'IRIS_NextFigureProperties', figureOptions);
end
