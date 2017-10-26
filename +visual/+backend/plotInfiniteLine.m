function [lineHandles, textHandles] = ...
    plotnfiniteLine(axesHandles, direction, location, varargin)
% plotInfiniteLine  Add infintely stretched vertical or horizontal line at specified position
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

lineHandles = [ ];
textHandles = [ ];

% Look for non-legend axes objects one level deep; this allows figure
% handles to be entered instead of axes objects.
axesHandles = findobj(axesHandles, 'type', 'axes', '-depth', 1, '-not', 'tag', 'legend');

if isempty(axesHandles) || isempty(direction) || isempty(location) || all(isnan(location))
    return
end

numAxes = length(axesHandles);
if numAxes>1
    for i = 1 : numAxes
        [ithLineHandle, ithTextHandle] = visual.line(axesHandles(i), direction, location, varargin{:});
        lineHandles = [lineHandles, ithLineHandle]; %#ok<AGROW>
        textHandles = [textHandles, ithTextHandle]; %#ok<AGROW>
    end
    return
end

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('visual.backend.plotInfiniteLine');
    INPUT_PARSER.KeepUnmatched = true;
    INPUT_PARSER.addRequired('AxesHandles', @(x) isa(x, 'matlab.graphics.axis.Axes'));
    INPUT_PARSER.addRequired('Direction', @(x) any(strcmpi(x, {'vertical', 'horizontal'})));
    INPUT_PARSER.addRequired('Location', @(x) isnumeric(x) || isa(x, 'DateWrapper') || isa(x, 'datetime'));
    INPUT_PARSER.addParameter('Text', cell.empty(1, 0), @(x) ischar(x) || isa(x, 'string') || iscellstr(x(1:2:end)));
    INPUT_PARSER.addParameter('ExcludeFromLegend', true, @(x) isequal(x, true) || isequal(x, false) );
    INPUT_PARSER.addParameter({'LinePlacement', 'TimePosition'}, 'exactly', @(x) any(strcmpi(x, {'exactly', 'middle', 'before', 'after'})));

    % Legacy options
    INPUT_PARSER.addParameter('Caption', cell.empty(1, 0), @(x) ischar(x) || iscellstr(x(1:2:end)));
    INPUT_PARSER.addParameter('VPosition', '');
    INPUT_PARSER.addParameter('HPosition', '');
end
INPUT_PARSER.parse(axesHandles, direction, location, varargin{:});
opt = INPUT_PARSER.Options;
unmatched = INPUT_PARSER.UnmatchedInCell;
usingDefaults = INPUT_PARSER.UsingDefaultsInStruct;

% Handle shortcut syntax for Text=
if ~iscell(opt.Text) || size(opt.Text, 2)==1
    opt.Text = {'String=', opt.Text};
end

% Handle legacy options VPosition= and HPosition=
if ~usingDefaults.Caption
    opt.Text = {'String', opt.Caption};
    if ~usingDefaults.VPosition
        opt.Text = [opt.Text, {'VerticalPosition', opt.VPosition}];
    end
    if ~usingDefaults.HPosition
        opt.Text = [opt.Text, {'HorizontalPosition', opt.HPosition}];
    end
end
        
isVertical = strncmpi(direction, 'v', 1);

INF_LIM = 1e10;
LIM_MULTIPLE = 100;

if isVertical
    Z_COOR = -3;
else
    Z_COOR = -2;
end

%--------------------------------------------------------------------------

% Check for plotyy peers, and return the background axes object.
% axesHandles = grfun.mychkforpeers(axesHandles);

% Vertical lines: If this is a time series graph, convert the vline
% position to a date grid point.
if isVertical
    if isa(location, 'DateWrapper')
        xLim = get(axesHandles, 'XLim');
        if isa(xLim, 'datetime')
            location = resolveLinePlacement( );
        else
            location = dat2dec(location, 'centre');
            freq = getappdata(axesHandles, 'IRIS_FREQ');
            if ~isempty(freq) && isnumeric(freq) && isscalar(freq) ...
                    && any(freq==[0, 1, 2, 4, 6, 12, 52])
                dx = 0.5 / max(1, freq);
                switch opt.LinePlacement
                case 'before'
                    location = location - dx;
                case 'after'
                    location = location + dx;
                end
            end
        end
    end
end

% Switch to left y-axis
try
    if strcmp(get(axesHandles, 'YAxisLocation'), 'right')
        yyaxis left
    end
end

xLim = get(axesHandles, 'XLim');
yLim = get(axesHandles, 'YLim');
xWidth = xLim(2) - xLim(1);
yHeight = yLim(2) - yLim(1);
for i = 1 : numel(location)
    if isVertical
        xData = location([i, i]);
        yData = [yLim(1)-LIM_MULTIPLE*yHeight, yLim(2)+LIM_MULTIPLE*yHeight];
    else
        xData = [xLim(1)-LIM_MULTIPLE*xWidth, xLim(2)+LIM_MULTIPLE*xWidth];
        yData = location([i, i]);
    end
    zData = Z_COOR*ones(size(xData));
    % Function line( ) always adds line objects to existing graphs even if
    % the NextPlot option is 'replace'.
    ithLineHandle = line( ...
        xData, yData, zData, ...
        'Parent', axesHandles, ...
        'Color', [0, 0, 0], ...
        'YLimInclude', 'off', 'XLimInclude', 'off', ...
        unmatched{:} ...
    );
    lineHandles = [lineHandles, ithLineHandle]; %#ok<AGROW>
    
    % Add annotation.
    if ~isempty(opt.Text) && isVertical
        ithTextHandle = visual.backend.createCaption( ...
            axesHandles, location(i), ...
            opt.Text{:} ...
        );
        textHandles = [textHandles, ithTextHandle]; %#ok<AGROW>
    end
end

% Make sure ZLim includes Z_COOR.
zLim = get(axesHandles, 'ZLim');
zLim(1) = min(zLim(1), Z_COOR);
zLim(2) = max(zLim(2), 0);
set(axesHandles, 'ZLim', zLim);

if isempty(lineHandles)
    return
end

if isVertical
    set(lineHandles, 'tag', 'vline');
    set(textHandles, 'tag', 'vline-caption');
    bkgLabel = 'VLine';
else
    set(lineHandles, 'tag', 'hline');
    bkgLabel = 'HLine';
end

for i = 1 : numel(lineHandles)
    setappdata(lineHandles(i), 'IRIS_BackgroundLevel', Z_COOR);
end
visual.backend.moveToBackground(axesHandles);

if opt.ExcludeFromLegend
    grfun.excludefromlegend(lineHandles);
end

return


    function datetimeLocation = resolveLinePlacement( )
        axesPositionWithinPeriod = getappdata(axesHandles, 'IRIS_PositionWithinPeriod');
        if isempty(axesPositionWithinPeriod)
            axesPositionWithinPeriod = 'start';
        end
        datetimeLocation = datetime(location, axesPositionWithinPeriod);
        if strcmpi(opt.LinePlacement, 'before')
            [~, halfDuration] = duration(location);
            datetimeLocation = datetimeLocation - halfDuration;
        elseif strcmpi(opt.LinePlacement, 'after')
            [~, halfDuration] = duration(location);
            datetimeLocation = datetimeLocation + halfDuration;
        end
    end
end
