function [hAx, hPlotTrue, hPlotFalse] = spy(varargin)
% spy  Visualise tseries observations that pass a test.
%
% Syntax
% =======
%
%     [hAx, hTrue, hFalse] = spy(x, ...)
%     [hAx, hTrue, hFalse] = spy(range, x, ...)
%
%
% Input arguments
% ================
%
% * `x` [ Series ] - Input time series whose observations that pass or fail
% a test will be plotted as markers.
%
% * `range` [ Series ] - Date range on which the tseries observations will
% be visualised; if not specified the entire available range will be used.
%
%
% Output arguments
% =================
%
% * `hAx` [ Axes ] - Handle to the axes created.
%
% * `hTrue` [ Line ] - Handle to the marks plotted for the observations
% that pass the test.
%
% * `hFalse` [ Line ] - Handle to the marks plotted for the observations
% that fail the test.
%
%
% Options
% ========
%
% * `'Names='` [ cellstr ] - Names that will be used to annotate individual
% columns of the input tseries object.
%
% * `'ShowTrue='` [ *`true`* | `false` ] - Display marks for the
% observations that pass the test.
%
% * `'ShowFalse='` [ `true` | *`false`* ] - Display marks for the
% observations that fail the test.
%
% * `'Test='` [ function_handle | *@(x)~isnan(x)* ] - Test applied to each
% observations; only the values returning a true will be displayed.
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `spy` for all options available.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if all(ishghandle(varargin{1})) ...
        && strcmpi(get(varargin{1}(1), 'type'), 'axes')
    hAx = varargin{1}(1);
    varargin(1) = [ ];
else
    hAx = gca( );
end

if isnumeric(varargin{1})
    range = varargin{1};
    varargin(1) = [ ];
else
    range = Inf;
end

this = varargin{1};
varargin(1) = [ ];

% Parse input arguments.
P = inputParser( );
P.addRequired('range', @isnumeric);
P.addRequired('x', @(x) isa(x, 'tseries'));
P.parse(range, this);

% Parse options.
[opt, varargin] = passvalopt('tseries.spy', varargin{:});
freq = get(this, 'freq');

%--------------------------------------------------------------------------

[x, range] = rangedata(this, range);
x = x(:, :, 1);
x = opt.test(x.');
if ~islogical(x)
    x = logical(x);
end
time = dat2dec(range, 'centre');
xCoor = repmat(1 : size(x, 2), size(x, 1), 1);
xCoor = time(xCoor);
yCoor = repmat(1 : size(x, 1), 1, size(x, 2));

if opt.ShowTrue
    markerTrue = '.';
else
    markerTrue = 'none';
end
if opt.ShowFalse
    markerFalse = '.';
else
    markerFalse = 'none';
end
markerSize = get(gcf( ), 'DefaultLineMarkerSize')*1.5;

holdStatus = ishold(hAx);
hPlotTrue = plot(hAx, xCoor(x), yCoor(x), ...
    'LineStyle', 'None', 'Marker', markerTrue, 'MarkerSize', markerSize);
hold on;
hPlotFalse = plot(hAx, xCoor(~x), yCoor(~x), ...
    'LineStyle', 'None', 'Marker', markerFalse, 'MarkerSize', markerSize);
if ~holdStatus
    hold off;
end
set( gca( ), 'YDir', 'Reverse', 'YLim', [0, size(x, 1)+1], ...
    'XLim', round([xCoor(1)-0.5, xCoor(end)+0.5]) );

setappdata(hAx, 'IRIS_SERIES', true);
setappdata(hAx, 'IRIS_FREQ', freq);
setappdata(hAx, 'IRIS_XLIM_ADJUST', true);
mydatxtick(hAx, range, time, freq, range, opt);

set(hAx, 'GridLineStyle', ':');
yLim = [1, size(x, 1)];
if ~isempty(opt.names)
    set( hAx, 'YTick', yLim(1):yLim(end), 'YTickMode', 'Manual', ...
        'YTickLabel', opt.names, 'yTickLabelMode', 'Manual', ...
        'YLim', [0.5, yLim(end)+0.5], 'YLimMode', 'Manual', ...
        'PlotBoxAspectRatio', [size(x,2)+1, size(x,1)+1, 1] );
else
    yTick = get(hAx, 'YTick');
    yTick(yTick<1) = [ ];
    yTick(yTick>size(x, 1)) = [ ];
    yTick(yTick~=round(yTick)) = [ ];
    set(hAx, 'YTick', yTick, 'YTickMode', 'Manual');
end

set(hAx, 'PlotBoxAspectRatio', [size(x,2)+5, size(x,1)+2, 1]);
xlabel('');
if ~isempty(varargin)
    set(hPlotTrue, varargin{:});
end

end
