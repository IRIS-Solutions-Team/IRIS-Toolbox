function [axesHandle, hPlotTrue, hPlotFalse] = spy(varargin)
% spy  Visualise tseries observations that pass a test.
%
% __Syntax__
%
%     [axesHandle, hTrue, hFalse] = spy(x, ...)
%     [axesHandle, hTrue, hFalse] = spy(range, x, ...)
%
%
% __Input Arguments__
%
% * `x` [ Series ] - Input time series whose observations that pass or fail
% a test will be plotted as markers.
%
% * `range` [ Series ] - Date range on which the tseries observations will
% be visualised; if not specified the entire available range will be used.
%
%
% __Output Arguments__
%
% * `axesHandle` [ Axes ] - Handle to the axes created.
%
% * `hTrue` [ Line ] - Handle to the marks plotted for the observations
% that pass the test.
%
% * `hFalse` [ Line ] - Handle to the marks plotted for the observations
% that fail the test.
%
%
% __Options__
%
% * `'Interpreter='` [ `@auto` | char | string ] - Value assigned to the
% axes property `TickLabelInterpreter` to interpret the strings entered
% throught `Names=`; `@uato` means `TickLabelInterpreter` will not be
% changed.
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
% * `'Squeeze='` [ `true` | *`false`*] - Adjust the PlotBoxAspecgtRatio
% property to squeeze the graph.
%
% * `'Test='` [ function_handle | *@(x)~isnan(x)* ] - Test applied to each
% observations; only the values returning a true will be displayed.
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `spy` for all options available.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

MARKER_SIZE_MULTIPLIER = 1.5;

if all(ishghandle(varargin{1})) ...
        && strcmpi(get(varargin{1}(1), 'type'), 'axes')
    axesHandle = varargin{1}(1);
    varargin(1) = [ ];
else
    axesHandle = gca( );
end

if isnumeric(varargin{1})
    range = varargin{1};
    varargin(1) = [ ];
else
    range = Inf;
end

this = varargin{1};
varargin(1) = [ ];

persistent parser
if isempty(parser)
    parser = extend.InputParser('tseries.spy');
    parser.KeepUnmatched = true;
    parser.addRequired('Axes', @(x) all(ishandle(x)));
    parser.addRequired('Range', @DateWrapper.validateDateInput);
    parser.addRequired('TimeSeries', @(x) isa(x, 'tseries'));
    parser.addParameter('ShowTrue', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('ShowFalse', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Squeeze', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Interpreter', 'none', @(x) isequal(x, @auto) || ischar(x) || isa(x, string));
    parser.addParameter({'Names', 'Name'}, { }, @(x) ischar(x) || iscellstr(x) || isa(x, string));
    parser.addParameter('Test', @isfinite, @(x) isa(x, 'function_handle'));
    parser.addDateOptions('TimeSubscriptable');
end
parser.parse(axesHandle, range, this, varargin{:});
opt = parser.Options;
freq = get(this, 'freq');
unmatched = parser.UnmatchedInCell;
if ~iscellstr(opt.Names)
    opt.Names = cellstr(opt.Names);
end

%--------------------------------------------------------------------------

this.Data = this.Data(:, :);
if ~isequal(range, Inf)
    this = clip(this, range(1), range(end));
end
x = opt.Test(this.Data);
if ~islogical(x)
    x = logical(x);
end
numOfPeriods = size(this.Data, 1);
numOfColumns = size(this.Data, 2);
this.Data = repmat(1:numOfColumns, numOfPeriods, 1);

colorOrder = get(axesHandle, 'ColorOrder');
colorOrderIndex = get(axesHandle, 'ColorOrderIndex');
markerSize = get(gcf( ), 'DefaultLineMarkerSize') * MARKER_SIZE_MULTIPLIER;

colorTrue = colorOrder(colorOrderIndex, :);
colorOrderIndex = colorOrderIndex + 1;
if opt.ShowTrue
    markerTrue = '.';
else
    markerTrue = 'none';
end

colorFalse = colorOrder(colorOrderIndex, :);
colorOrderIndex = colorOrderIndex + 1;
if opt.ShowFalse
    markerFalse = '.';
else
    markerFalse = 'none';
end

holdStatus = ishold(axesHandle);

thisTrue = this;
thisTrue.Data(~x) = NaN;
hPlotTrue = plot( axesHandle, thisTrue.Range, thisTrue, ...
                  'XLimMargins', true, ...
                  'LineStyle', 'None', ...
                  'Color', colorTrue, ...
                  'Marker', markerTrue, ...
                  'MarkerSize', markerSize, ...
                  unmatched{:} );

hold on

thisFalse = this;
thisFalse.Data(x) = NaN;
hPlotFalse = plot( axesHandle, thisFalse.Range, thisFalse, ...
                   'XLimMargins', true, ...
                   'LineStyle', 'None', ...
                   'Color', colorFalse, ...
                   'Marker', markerFalse, ...
                   'MarkerSize', markerSize, ...
                   unmatched{:} );

if ~holdStatus
    hold off
end

set( axesHandle, ...
     'ColorOrderIndex', colorOrderIndex, ...
     'YDir', 'Reverse', ...
     'YLim', [0.5, numOfColumns+0.5] );

if ~opt.ShowTrue
    visual.excludeFromLegend(hPlotTrue);
end
if ~opt.ShowFalse
    visual.excludeFromLegend(hPlotFalse);
end

set(axesHandle, 'GridLineStyle', ':');
yLim = [1, numOfColumns];
if ~isempty(opt.Names)
    printRowNames( );
else
    yTick = get(axesHandle, 'YTick');
    yTick(yTick<1) = [ ];
    yTick(yTick>numOfColumns) = [ ];
    yTick(yTick~=round(yTick)) = [ ];
    set(axesHandle, 'YTick', yTick, 'YTickMode', 'Manual');
end

if opt.Squeeze
    set(axesHandle, 'PlotBoxAspectRatio', [numOfPeriods+5, numOfColumns+2, 1]);
end

return


    function printRowNames( )
        try
            if ~isequal(opt.Interpreter, @auto)
                set(axesHandle, 'TickLabelInterpreter', opt.Interpreter);
            end
        end
        set( axesHandle, ...
             'YTick', yLim(1):yLim(end), ...
             'YTickMode', 'Manual', ...
             'YTickLabel', opt.Names, ...
             'yTickLabelMode', 'Manual', ...
             'YLim', [0.5, yLim(end)+0.5], ...
             'YLimMode', 'Manual', ...
             'PlotBoxAspectRatio', [numOfPeriods+1, numOfColumns+1, 1] );
    end%
end%

