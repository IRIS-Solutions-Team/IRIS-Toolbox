function [h1, h2, h3, range, data, grid] = plotpred(varargin)
% plotpred  Visualize multi-step-ahead predictions.
%
% Syntax
% =======
%
%     [Hx, Hy, Hm] = plotpred(X, Y, ...)
%     [Hx, Hy, Hm] = plotpred(Ax, X, Y, ...)
%     [Hx, Hy, Hm] = plotpred(Ax, Range, X, Y, ...)
%
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input data with time series observations.
%
% * `Y` [ tseries ] - Prediction data arranged as described below; the
% prediction data returned from a Kalman filter can be used, see Example
% below.
%
% * `Ax` [ numeric ] - Handle to axes object in which the data will be
% plotted.
%
% * `Range` [ numeric | Inf ] - Date range on which the input data will be
% plotted.
%
%
% Output arguments
% =================
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
% Options
% ========
%
% * `'connect='` [ *`true`* | `false` ] - Connect the prediction lines, 
% `Y`,  with the corresponding observation in `X`.
%
% * `'firstMarker='` [ *`'none'`* | char ] - Type of marker displayed at
% the start of each prediction line.
%
% * `'showNaNLines='` [ *`true`* | `false` ] - Show or remove lines with
% whose starting points are NaN (missing observations).
%
% See help on [`plot`](tseries/plot) and on the built-in function
% `plot` for options available.
%
%
% Description
% ============
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
% Example
% ========
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


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if isempty(varargin)
    return
end

% Handle to axes object.
if length(varargin{1})==1 && ishandle(varargin{1})
    ax = varargin{1};
    varargin(1) = [ ];
else
    ax = get(gcf( ), 'currentAxes');
    if isempty(ax)
        ax = axes('box', 'on');
    end
end

% Range.
if isnumeric(varargin{1})
    range = varargin{1};
    varargin(1) = [ ];
else
    range = Inf;
end

% Input data.
x1 = varargin{1};
varargin(1) = [ ];
if ~isempty(varargin) && isa(varargin{1}, 'tseries')
    % Syntax with two separate tseries, plotpred(X, Y).
    x2 = varargin{1};
    varargin(1) = [ ];
else
    % Syntax with one combined tseries, plotpred([X, Y]).
    x2 = x1;
    x2.data = x2.data(:, 2:end);
    x1.data = x1.data(:, 1);
end

[opt, varargin] = passvalopt('tseries.plotpred', varargin);

%--------------------------------------------------------------------------

if ~isempty(x1)
    f1 = DateWrapper.getFrequencyFromNumeric(x1.start);
    f2 = DateWrapper.getFrequencyFromNumeric(x2.start);
    if f1~=f2
        utils.error('tseries:plotpred', ...
            'Input data must have the same date frequency.');
    end
    [data, fullRange] = rangedata( [x1, x2] );
else
    nPer = size(x2.data, 1);
    x1 = x2;
    x1.data = nan(nPer, 1);
    x1.Comment = {''};
    [data, fullRange] = rangedata(x2);
end
nAhead = size(data, 2);

if opt.connect
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
fig = get(ax, 'parent');
figNextPlot = get(fig, 'nextPlot');
axNextPlot = get(ax, 'nextPlot');
appPlotHoldStyle = getappdata(ax, 'PlotHoldStyle');

% Plot the actual data.
[h1, ~, data1] = plot(ax, range, x1, varargin{:}, opt.firstline{:});

% Hold all.
set(fig, 'NextPlot', 'add');
set(ax, 'NextPlot', 'add');
setappdata(ax, 'PlotHoldStyle', true);

% Plot predictions.
[h2, ~, data2, grid] = plot(ax, range, x2, varargin{:}, opt.predlines{:});
set(h2, 'tag', 'plotpred');

% Plot start points.
H2color = get(h2, 'color');
h3 = plot(ax, range, startPoint);
set(h3, {'color'}, H2color, 'marker', opt.firstmarker);

% Restore hold settings.
set(fig, 'NextPlot', figNextPlot);
set(ax, 'NextPlot', axNextPlot);
setappdata(ax, 'PlotHoldStyle', appPlotHoldStyle);

if ~isempty(h1) && ~isempty(h2) ...
        && ~any( strcmpi(varargin(1:2:end), 'linestyle') ) ...
        && ~any( strcmpi(opt.predlines(1:2:end), 'linestyle') )
    set(h2, 'linestyle', '--');
end

data = [ data1, data2 ];

return




    function data2 = rearrangePredictionData( )
        nPer = size(data, 1);
        data = [ data; nan(nAhead-1, nAhead) ];        
        data2 = nan(nPer+nAhead-1, nPer);
        for t = 1 : nPer
            row = t+(0:nAhead-1);
            data2(row, t, :) = diag( data(t+(0:nAhead-1), :) );
        end
        data2 = data2(1:nPer, :);    
        % Remove lines with missing starting point.
        if ~opt.shownanlines
            ixDiagNaN = isnan( diag(data2, diagPos) );
            data2(:, ixDiagNaN) = NaN;
        end
    end




    function startPoint = findStartPoint( )
        startPoint = nan(nPer+nAhead-1, nPer);
        for iiCol = 1 : size(data2, 2)
            pos = find( ~isnan(data2(:, iiCol)), 1 );
            if ~isempty(pos)
                startPoint(pos, iiCol) = data2(pos, iiCol);
            end
        end
        startPoint = replace(x2, startPoint(1:nPer, :), fullRange(1));
    end




    function determinePlotRange( )
        range = [ range(1), range(end) ];
        if ~isfinite(range(1))
            range(1) = fullRange(1);
        end
        if ~isfinite(range(end))
            range(end) = fullRange(end);
        end
        range = range(1) : range(end);
    end
end
