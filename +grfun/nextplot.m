function varargout = nextplot(varargin)
% nextplot  Simplify use of standard subplot function.
%
% __Syntax for New Figure Window With Certain Subplot Division__
%
%     Fig = grfun.nextplot([NumRows, NumColumns], ...)
%     Fig = grfun.nextplot(NumRows, NumColumns, ...)
%
%
% __Syntax for New Graph at Next Subplot Position__
%
%     [Axes, Fig, Count]  = grfun.nextplot( )
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.


%--------------------------------------------------------------------------

skipOnePosition = ~isempty(varargin) && isequaln(varargin{1}, NaN);

if ~isempty(varargin) && ~skipOnePosition
    % Open a new figure and initialise subplot data.
    varargout = cell(1, 1);
    varargout{1} = initialize(varargin{:});
    return
end

hCurrentFigure = get(0, 'CurrentFigure');
if isempty(hCurrentFigure)
    error('No figure window open, cannot use grfun.nextplot( )');
end

numRows = getappdata(hCurrentFigure, 'IRIS_NEXTPLOT_NUM_ROWS');
numColumns = getappdata(hCurrentFigure, 'IRIS_NEXTPLOT_NUM_COLUMNS');
currentPosition = getappdata(hCurrentFigure, 'IRIS_NEXTPLOT_CURRENT_POSITION');

test = @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>=0 && isfinite(x);
if ~test(numRows) || ~test(numColumns) || ~test(currentPosition)
    error('Current figure window is not configured for grfun.nextplot( )');
end

hNewFigure = [ ];
% Open a new figure if the number of subplots exceeds the maximum.
if currentPosition>=numRows*numColumns
    currentPosition = 0;
    figureProp = getappdata(hCurrentFigure, 'IRIS_NEXTPLOT_FIGURE_PROP');
    if isempty(figureProp)
        hNewFigure = figure( );
    else
        hNewFigure = figure(figureProp);
    end
    setappdata(hNewFigure, 'IRIS_NEXTPLOT_NUM_ROWS', numRows);
    setappdata(hNewFigure, 'IRIS_NEXTPLOT_NUM_COLUMNS', numColumns);
    setappdata(hNewFigure, 'IRIS_NEXTPLOT_CURRENT_POSITION', currentPosition);
    hCurrentFigure = hNewFigure;
end

% Add new subplot to the current figure.
currentPosition = currentPosition + 1;
if ~skipOnePosition
    hAxes = subplot(numRows, numColumns, currentPosition);
    grfun.clicktocopy(hAxes);
else
    hAxes = [ ];
end

setappdata(hCurrentFigure, 'IRIS_NEXTPLOT_CURRENT_POSITION', currentPosition);
varargout{1} = hAxes;
varargout{2} = hCurrentFigure;
varargout{3} = currentPosition;

end


function hFigure = initialize(varargin)
    persistent INPUT_PARSER
    if isempty(INPUT_PARSER)
        test1 = @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>0;
        test2 = @(x) isnumeric(x) && any(numel(x)==[1, 2]) && all(x==round(x)) && all(x>0);
        INPUT_PARSER = extend.InputParser('grfun/nextplot');
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
            % nextplot(totalCount, ...)
            totalCount = numRows;
            [numRows, numColumns] = grfun.optimizeSubplot(totalCount);
        else
            % nextplot([numRows, numColumns], ...)
            numColumns = numRows(2);
            numRows = numRows(1);
        end
    end
    hFigure = figure(figureOptions);
    setappdata(hFigure, 'IRIS_NEXTPLOT_NUM_ROWS', numRows);
    setappdata(hFigure, 'IRIS_NEXTPLOT_NUM_COLUMNS', numColumns);
    setappdata(hFigure, 'IRIS_NEXTPLOT_CURRENT_POSITION', 0);
    setappdata(hFigure, 'IRIS_NEXTPLOT_FIGURE_PROP', figureOptions);
end
