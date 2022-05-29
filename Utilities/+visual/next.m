function varargout = next(varargin)
% next  Simplify use of standard subplot function
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team


%--------------------------------------------------------------------------

skipOnePosition = ~isempty(varargin) && isequaln(varargin{1}, NaN);

if ~isempty(varargin) && ~skipOnePosition
    % Open a new figure and initialize subplot data
    varargout = cell(1, 1);
    varargout{1} = initialize(varargin{:});
    return
end

currentFigureHandle = get(0, 'CurrentFigure');
if isempty(currentFigureHandle)
    THIS_ERROR = { 'Visual:NoFigureOpenForNext'
                   'No figure window open for visual.next(~) ' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

numOfRows = getappdata(currentFigureHandle, 'IRIS_NextNumRows');
numOfColumns = getappdata(currentFigureHandle, 'IRIS_NextNumColumns');
currentPosition = getappdata(currentFigureHandle, 'IRIS_NextCurrentPosition');

test = @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>=0 && isfinite(x);
if ~test(numOfRows) || ~test(numOfColumns) || ~test(currentPosition)
    THIS_ERROR = { 'Visual:FigureNotConfiguredForNext'
                   'Current figure window is not configured for visual.next(~) ' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

newFigureHandle = [ ];
% Open a new figure if the number of subplots exceeds the maximum
if currentPosition>=numOfRows*numOfColumns
    currentPosition = 0;
    figureProp = getappdata(currentFigureHandle, 'IRIS_NextFigureProperties');
    if isempty(figureProp)
        newFigureHandle = figure( );
    else
        newFigureHandle = figure(figureProp);
    end
    setappdata(newFigureHandle, 'IRIS_NextNumRows', numOfRows);
    setappdata(newFigureHandle, 'IRIS_NextNumColumns', numOfColumns);
    setappdata(newFigureHandle, 'IRIS_NextCurrentPosition', currentPosition);
    currentFigureHandle = newFigureHandle;
end

% Add new subplot to the current figure
currentPosition = currentPosition + 1;
if ~skipOnePosition
    axesHandle = subplot(numOfRows, numOfColumns, currentPosition);
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


%
% Local Functions
%


function figureHandle = initialize(varargin)
    persistent parser
    if isempty(parser)
        test1 = @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>0;
        test2 = @(x) isnumeric(x) && any(numel(x)==[1, 2]) && all(x==round(x)) && all(x>0);
        parser = extend.InputParser('visual/next');
        parser.KeepUnmatched = true;
        parser.addRequired('NumRows', @(x) test1(x) || test2(x));
        parser.addOptional('NumColumns', 1, @(x) test1(x));
    end
    parser.parse(varargin{:});
    numOfRows = parser.Results.NumRows;
    numOfColumns = parser.Results.NumColumns;
    figureOptions = parser.Unmatched;

    if any(strcmp(parser.UsingDefaults, 'NumColumns'))
        if numel(numOfRows)==1
            % next(totalCount, ...)
            totalCount = numOfRows;
            [numOfRows, numOfColumns] = visual.backend.optimizeSubplot(totalCount);
        else
            % next([numOfRows, numOfColumns], ...)
            numOfColumns = numOfRows(2);
            numOfRows = numOfRows(1);
        end
    end
    figureHandle = figure(figureOptions);
    setappdata(figureHandle, 'IRIS_NextNumRows', numOfRows);
    setappdata(figureHandle, 'IRIS_NextNumColumns', numOfColumns);
    setappdata(figureHandle, 'IRIS_NextCurrentPosition', 0);
    setappdata(figureHandle, 'IRIS_NextFigureProperties', figureOptions);
end%

