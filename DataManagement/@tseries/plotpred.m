function [h1, h2, h3, range, data] = plotpred(varargin)
% plotpred  Visualize multi-step-ahead prediction
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [Hx, Hy, Hm] = plotpred(~Ax, ~Range, X, Y, ...)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input data with time series observations.
%
% * `Y` [ tseries ] - Prediction data arranged as described below; the
% prediction data returned from a Kalman filter can be used, see Example
% below.
%
% * `~Ax` [ numeric ] - Handle to axes object in which the data will be
% plotted.
%
% * `~Range` [ numeric | Inf ] - Date range on which the input data will be
% plotted.
%
%
% __Output arguments__
%
% * `Hx` [ numeric ] - Handles to a line object showing the time series
% observations (the first column, `X`, in the input data).
%
% * `Hy` [ numeric ] - Handles to line objects showing the Kalman filter
% predictions (the second and further columns, `Y`, in the input data).
%
% * `Hm` [ numeric ] - Handles to one-point line objects displaying a
% marker at the start of each line.
%
%
% __Options__
%
% * `Connect=true` [ `true` | `false` ] - Connect the prediction lines, 
% `Y`,  with the corresponding observation in `X`.
%
% * `FirstMarker='None'` [ `'None'` | char ] - Type of marker displayed at
% the start of each prediction line.
%
% * `HandleVisibility={'on', 'on', 'on'}` [ cellstr ] - Visibility of
% handles to the lines created; the first element sets the visibility for
% the first line `Hx`, the second element sets the visibility for for the
% prediction lines `Hy` and the third element sets the visibility of the
% starting point markers, `Hm`.
%
% * `ShowNaNLines=true` [ `true` | `false` ] - Show or remove lines with
% whose starting points are `NaN` (missing observations).
%
% See help on [`plot`](tseries/plot) and on the built-in function
% `plot` for options available.
%
%
% __Description__
%
% The input data `Y` need to be a multicolumn time series (tseries object), 
% with one-step-ahead predictions `x(t|t-1)` in the first column, 
% two-step-ahead predictions `x(t|t-2)` in the second column, and so on.
% Note the timing assumptions.
%
% If `x1` is a series with one-step-ahead predictions `x(t+1|t)`, `x2` is a
% series with two-step-ahead predictions `x(t+2|t)`, and so on, while `x`
% is a series with the actual observations `x(t)`, the following command
% will create a time series that can be then passed into `plotpred( )`:
%
%     p = [ x1{-1}, x2{-2}, ..., xn{-n} ];
%     plotpred(x, p);
%
%
% __Example__
%
% The `plotpred( )` function can be used with prediction-step data returned
% from a Kalman filter, [`filter`](model/filter). The prediction-step data
% need to be specifically requested using the `'output='` option (as they
% are not included in the output database by default), with the prediction
% horizon assigned in the `'ahead='` option (the horizon is `1` by
% default):
%
%     [~, g] = filter(m, d, startDate:endDate, ...
%         'output=', 'pred', 'meanOnly=', true, 'ahead=', 8); 
%
%     figure( );
%     plotpred(startdate:enddate, d.x, g.pred.x); 
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

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
if DateWrapper.validateRangeInput(varargin{1})
    range = varargin{1};
    varargin(1) = [ ];
else
    range = Inf;
end

% Input data.
x1 = varargin{1};
varargin(1) = [ ];
if ~isempty(varargin) && isa(varargin{1}, 'TimeSubscriptable')
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
    f1 = DateWrapper.getFrequencyAsNumeric(x1.Start);
    f2 = DateWrapper.getFrequencyAsNumeric(x2.Start);
    if f1~=f2
        throw( exception.Base('Series:FrequencyMismatch', 'error'), ...
               Frequency.toChar(f1), Frequency.toChar(f2) );
    end
    [data, fullRange] = rangedata([x1, x2], range);
else
    numPeriods = size(x2.Data, 1);
    x1 = x2;
    x1.Data = nan(numPeriods, 1);
    x1 = resetComment(x1);
    [data, fullRange] = rangedata(x2, range);
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

x2 = replace(x2, data2, fullRange(1));

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
        startPoint = replace(x2, startPoint(1:numPeriods, :), fullRange(1));
    end%


    function determinePlotRange( )
        if isfinite(range(1))
            startDate = range(1);
        else
            startDate = fullRange(1);
        end
        if isfinite(range(end))
            endDate = range(end);
        else
            endDate = fullRange(end);
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
