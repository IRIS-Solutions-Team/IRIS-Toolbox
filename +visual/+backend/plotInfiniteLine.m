function [lineHandles, textHandles] = plotnfiniteLine(caller, varargin)
% plotInfiniteLine  Add infintely stretched vertical or horizontal line at specified position
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

lineHandles = gobjects(1 ,0);
textHandles = gobjects(1 ,0);

if ~isempty(varargin) && all(isgraphics(varargin{1}))
    axesHandle = varargin{1};
    varargin(1) = [ ];
    axesHandle = visual.backend.resolveAxesHandles('All', axesHandle);
    if isempty(axesHandle) 
        return
    end
else
    axesHandle = @gca;
end
    
if strcmp(caller, 'zeroline')
    location = 0;
else
    if isempty(varargin)
        return
    end
    location = varargin{1};
    varargin(1) = [ ];
    if ischar(location) || isa(location, 'str') || iscellstr(location)
        location = cellstr(location);
        for i = 1 : numel(location)
            location{i} = textinp2dat(location{i});
        end
        location = [ location{:} ];
    end
    if isempty(location)
        return
    end
end

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('visual.backend.plotInfiniteLine');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('AxesHandles', @(x) isequal(x, @gca) || all(isgraphics(x, 'Axes')));
    inputParser.addRequired('Caller', @(x) any(strcmpi(x, {'vline', 'hline', 'zeroline'})));
    inputParser.addRequired('Location', @(x) isnumeric(x) || isa(x, 'DateWrapper') || isa(x, 'datetime'));
    inputParser.addParameter('Text', cell.empty(1, 0), @(x) ischar(x) || isa(x, 'string') || iscellstr(x(1:2:end)));
    inputParser.addParameter('ExcludeFromLegend', true, @(x) isequal(x, true) || isequal(x, false) );
    inputParser.addParameter('HandleVisibility', 'Off', @(x) any(strcmpi(x, {'On', 'Off'})));
    inputParser.addParameter({'LinePlacement', 'TimePosition'}, 'exactly', @(x) any(strcmpi(x, {'exactly', 'middle', 'before', 'after'})));
    % Legacy options
    inputParser.addParameter('Caption', cell.empty(1, 0), @(x) ischar(x) || iscellstr(x(1:2:end)));
    inputParser.addParameter('VPosition', '');
    inputParser.addParameter('HPosition', '');
end
inputParser.parse(axesHandle, caller, location, varargin{:});
opt = inputParser.Options;
unmatched = inputParser.UnmatchedInCell;
usingDefaults = inputParser.UsingDefaultsInStruct;

if isequal(axesHandle, @gca)
    axesHandle = gca( );
end

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
        
isVertical = strncmpi(caller, 'v', 1);

INF_LIM = 1e10;
LIM_MULTIPLE = 100;

if isVertical
    Z_COOR = -3;
else
    Z_COOR = -2;
end

%--------------------------------------------------------------------------

numAxes = numel(axesHandle);
for a = 1 : numAxes
    h = axesHandle(a);
    % Check for plotyy peers, and return the background axes object.
    h = grfun.mychkforpeers(h);

    % Vertical lines: If this is a time series graph, convert the vline
    % position to a date grid point.
    if isVertical
        if isa(location, 'DateWrapper')
            xLim = get(h, 'XLim');
            if isa(xLim, 'datetime')
                location = resolveLinePlacement( );
            else
                location = dat2dec(location, 'centre');
                freq = getappdata(h, 'IRIS_FREQ');
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

    if isnumeric(h)
        % Handle to axes can be a numeric which passes the isgraphics
        % test but cannot be called with yyaxis. Convert to graphics here.
        h = visual.backend.numericToHandle(h);
    end

    % Switch to left y-axis if needed for vertical lines; horizontal lines have
    % y-axis specific location so they must be drawn on the side requested
    switchedToLeft = false;
    if isVertical
        switchedToLeft = visual.backend.switchToLeft(h);
    end

    xLim = get(h, 'XLim');
    yLim = get(h, 'YLim');
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
            'Parent', h, ...
            'Color', [0, 0, 0], ...
            'YLimInclude', 'off', 'XLimInclude', 'off', ...
            unmatched{:} ...
        );
        
        % Add annotation.
        if ~isempty(opt.Text) && isVertical
            ithTextHandle = visual.backend.createCaption( ...
                h, location(i), ...
                opt.Text{:} ...
            );
            textHandles = [textHandles, ithTextHandle]; %#ok<AGROW>
        end

        setappdata(ithLineHandle, 'IRIS_BackgroundLevel', Z_COOR);
        lineHandles = [lineHandles, ithLineHandle]; %#ok<AGROW>
    end

    % Make sure ZLim includes Z_COOR.
    zLim = get(h, 'ZLim');
    zLim(1) = min(zLim(1), Z_COOR);
    zLim(2) = max(zLim(2), 0);
    set(h, 'ZLim', zLim);

    visual.backend.moveToBackground(h);
    if switchedToLeft
        yyaxis(h, 'right');
    end

    if opt.ExcludeFromLegend
        visual.excludeFromLegend(lineHandles);
    end

    if ~isempty(lineHandles)
        set( ...
            lineHandles, ...
            'HandleVisibility', opt.HandleVisibility, ...
            'Tag', caller ...
        );
    end

    if ~isempty(textHandles)
        set( ...
            textHandles, ...
            'HandleVisibility', opt.HandleVisibility, ...
            'Tag', [caller, '-caption'] ...
        );
    end
end

return


    function datetimeLocation = resolveLinePlacement( )
        axesPositionWithinPeriod = getappdata(h, 'IRIS_PositionWithinPeriod');
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
    end%
end%
