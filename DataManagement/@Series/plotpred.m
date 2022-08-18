function [h1, h2, h3, range, data] = plotpred(varargin)

if isempty(varargin)
    return
end

% Handle to axes object
if length(varargin{1})==1 && ishandle(varargin{1})
    handleAxes = varargin{1};
    varargin(1) = [ ];
else
    handleAxes = visual.backend.getCurrentAxesIfExists( );
    if isempty(handleAxes)
        handleAxes = axes('Box', 'On');
    end
end

% Plot range
if validate.range(varargin{1})
    range = double(varargin{1});
    varargin(1) = [ ];
else
    range = Inf;
end

% Input data.
x1 = varargin{1};
varargin(1) = [ ];
if ~isempty(varargin) && isa(varargin{1}, 'Series')
    % Syntax with two separate time series, plotpred(X, Y)
    x2 = varargin{1};
    varargin(1) = [ ];
else
    % Syntax with one combined time series, plotpred([X, Y])
    x2 = x1;
    x2.Data = x2.Data(:, 2:end);
    x1.Data = x1.Data(:, 1);
end

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.plotpred');
    inputParser.KeepUnmatched = true;
    inputParser.addParameter('Connect', true, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('FirstLine', { }, @(x) iscell(x) && iscellstr(x(1:2:end)));
    inputParser.addParameter('HandleVisibility', {'on', 'on', 'on'}, @(x) iscellstr(x) && numel(x)==3 && any(strcmpi(x{1}, {'on', 'off'})) && any(strcmpi(x{2}, {'on', 'off'})) && any(strcmpi(x{3}, {'on', 'off'})));
    inputParser.addParameter('PredLines', { }, @(x) iscell(x) && iscellstr(x(1:2:end)));
    inputParser.addParameter({'FirstMarker', 'FirstMarkers', 'Startpoint', 'StartPoints'}, '.', @(x) ischar(x) && any(strcmpi(x, {'none', '+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'})));
    inputParser.addParameter('ShowNaNLines', true, @(x) isequal(x, true) || isequal(x, false));
end
inputParser.parse(varargin{:});
opt = inputParser.Options;
unmatched = inputParser.UnmatchedInCell;

%--------------------------------------------------------------------------

if ~isempty(x1)
    f1 = dater.getFrequency(x1.Start);
    f2 = dater.getFrequency(x2.Start);
    if f1~=f2
        throw( exception.Base('Series:FrequencyMismatch', 'error'), ...
               Frequency.toChar(f1), Frequency.toChar(f2) );
    end
    [data, fullStart, fullEnd] = getDataFromTo([x1, x2], range);
else
    numPeriods = size(x2.Data, 1);
    x1 = x2;
    x1.Data = nan(numPeriods, 1);
    x1 = resetComment(x1);
    [data, fullStart, fullEnd] = getDataFromTo(x2, range);
end
numAhead = size(data, 2);

if opt.Connect
    diagPos = 0;
else
    diagPos = -1;
    data(:, 1) = NaN;
end

% Re-arrange the prediction matrix.
data2 = rearrangePredictionData( );

% Find first data point in each column of the prediction matrix; these will
% be plotted separately for formatting purposes (markers, etc).
startPoint = findStartPoint( );

% Determine the plot range.
determinePlotRange( );

x2 = replace(x2, data2, fullStart);

% Store current `hold` settings.
isHold = ishold(handleAxes);

% Plot the actual data.
[h1, ~, data1] = plot(handleAxes, range, x1, unmatched{:}, opt.FirstLine{:});

% Hold all.
hold(handleAxes, 'on');

% Plot predictions.
[h2, ~, data2] = plot(handleAxes, range, x2, unmatched{:}, opt.PredLines{:});
set(h2, 'tag', 'plotpred');

% Plot start points.
H2color = get(h2, 'color');
h3 = plot(handleAxes, range, startPoint);
set(h3, {'color'}, H2color, 'marker', opt.FirstMarker);

% Restore hold settings.
if ~isHold
    hold(handleAxes, 'off');
end

if ~isempty(h1) && ~isempty(h2) ...
        && ~any( strcmpi(unmatched(1:2:end), 'linestyle') ) ...
        && ~any( strcmpi(opt.PredLines(1:2:end), 'linestyle') )
    set(h2, 'linestyle', '--');
end

data = [ data1, data2 ];

setHandleVisibility( );

return


    function data2 = rearrangePredictionData( )
        numPeriods = size(data, 1);
        data = [ data; nan(numAhead-1, numAhead) ];        
        data2 = nan(numPeriods+numAhead-1, numPeriods);
        for t = 1 : numPeriods
            row = t+(0:numAhead-1);
            data2(row, t, :) = diag( data(t+(0:numAhead-1), :) );
        end
        data2 = data2(1:numPeriods, :);    
        % Remove lines with missing starting point.
        if ~opt.ShowNaNLines
            ixDiagNaN = isnan( diag(data2, diagPos) );
            data2(:, ixDiagNaN) = NaN;
        end
    end%


    function startPoint = findStartPoint( )
        startPoint = nan(numPeriods+numAhead-1, numPeriods);
        for iiCol = 1 : size(data2, 2)
            pos = find( ~isnan(data2(:, iiCol)), 1 );
            if ~isempty(pos)
                startPoint(pos, iiCol) = data2(pos, iiCol);
            end
        end
        startPoint = replace(x2, startPoint(1:numPeriods, :), fullStart);
    end%


    function determinePlotRange( )
        if isfinite(range(1))
            startDate = range(1);
        else
            startDate = fullStart;
        end
        if isfinite(range(end))
            endDate = range(end);
        else
            endDate = fullEnd;
        end
        range = startDate : endDate;
    end%


    function setHandleVisibility( )
        opt.HandleVisibility = lower(opt.HandleVisibility);
        if ~isempty(h1)
            set(h1, 'HandleVisibility', opt.HandleVisibility{1});
        end
        if ~isempty(h2)
            set(h2, 'HandleVisibility', opt.HandleVisibility{2});
        end
        if ~isempty(h3)
            set(h3, 'HandleVisibility', opt.HandleVisibility{3});
        end
    end%
end%

