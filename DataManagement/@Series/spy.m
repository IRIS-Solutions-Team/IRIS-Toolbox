function [axesHandle, hPlotTrue, hPlotFalse] = spy(varargin)

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
    parser = extend.InputParser('Series.spy');
    parser.KeepUnmatched = true;
    parser.addRequired('Axes', @(x) all(ishandle(x)));
    parser.addRequired('Range', @validate.date);
    parser.addRequired('InputSeries', @(x) isa(x, 'Series'));
    parser.addParameter('ShowTrue', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('ShowFalse', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Squeeze', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Interpreter', 'none', @(x) isequal(x, @auto) || ischar(x) || isa(x, string));
    parser.addParameter({'Names', 'Name'}, { }, @(x) ischar(x) || iscellstr(x) || isstring(x));
    parser.addParameter('Test', @isfinite, @(x) isa(x, 'function_handle'));
    parser.addParameter('TruePlotSettings', cell.empty(1, 0), @iscell);
    parser.addParameter('FalsePlotSettings', cell.empty(1, 0), @iscell);
    parser.addParameter('AxesSettings', cell.empty(1, 0), @iscell);
    parser.addDateOptions('Series');
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
numPeriods = size(this.Data, 1);
numColumns = size(this.Data, 2);
this.Data = repmat(1:numColumns, numPeriods, 1);

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
hPlotTrue = plot(  ...
    axesHandle, thisTrue.Range, thisTrue, ...
    'XLimMargins', true, ...
    'LineStyle', 'None', ...
    'Color', colorTrue, ...
    'Marker', markerTrue, ...
    'MarkerSize', markerSize, ...
    opt.TruePlotSettings{:}, ...
    unmatched{:} ...
);

hold(axesHandle, 'on');

thisFalse = this;
thisFalse.Data(x) = NaN;
hPlotFalse = plot( ...
    axesHandle, thisFalse.Range, thisFalse, ...
    'XLimMargins', true, ...
    'LineStyle', 'None', ...
    'Color', colorFalse, ...
    'Marker', markerFalse, ...
    'MarkerSize', markerSize, ...
    opt.FalsePlotSettings{:}, ...
    unmatched{:} ...
);

if ~holdStatus
    hold(axesHandle, 'off');
end

set( ...
    axesHandle, ...
    'ColorOrderIndex', colorOrderIndex, ...
    'YDir', 'Reverse', ...
    'YLim', [0.5, numColumns+0.5] ...
);

if ~opt.ShowTrue
    visual.excludeFromLegend(hPlotTrue);
end
if ~opt.ShowFalse
    visual.excludeFromLegend(hPlotFalse);
end

set(axesHandle, 'GridLineStyle', ':');
yLim = [1, numColumns];
if ~isempty(opt.Names)
    printRowNames( );
else
    yTick = get(axesHandle, 'YTick');
    yTick(yTick<1) = [ ];
    yTick(yTick>numColumns) = [ ];
    yTick(yTick~=round(yTick)) = [ ];
    set(axesHandle, 'YTick', yTick, 'YTickMode', 'Manual');
end

if opt.Squeeze
    set(axesHandle, 'PlotBoxAspectRatio', [numPeriods+5, numColumns+2, 1]);
end

if ~isempty(opt.AxesSettings)
    set(axesHandle, opt.AxesSettings{:});
end

return


    function printRowNames( )
        try
            if ~isequal(opt.Interpreter, @auto)
                set(axesHandle, 'TickLabelInterpreter', opt.Interpreter);
            end
        end
        set( ...
            axesHandle ...
            , 'YTick', yLim(1):yLim(end) ...
            , 'YTickMode', 'Manual' ...
            , 'YTickLabel', opt.Names ...
            , 'yTickLabelMode', 'Manual' ...
            , 'YLim', [0.5, yLim(end)+0.5] ...
            , 'YLimMode', 'Manual' ...
        );
    end%
end%

