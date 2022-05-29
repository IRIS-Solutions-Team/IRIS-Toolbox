% plotInfiniteLine  Add infintely stretched vertical or horizontal line at specified position
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [lineHandles, textHandles] = plotInfiniteLine(caller, varargin)

lineHandles = gobjects(1 ,0);
textHandles = gobjects(1 ,0);

if ~isempty(varargin) && all(isgraphics(varargin{1})) && ~isnumeric(varargin{1})
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
    if isempty(location)
        return
    end
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('visual.backend.plotInfiniteLine');
    parser.KeepUnmatched = true;
    parser.addRequired('AxesHandles', @(x) isequal(x, @gca) || all(isgraphics(x, 'Axes')));
    parser.addRequired('Caller', @(x) any(strcmpi(x, {'vline', 'hline', 'zeroline'})));
    parser.addRequired('Location', @(x) isnumeric(x) || isa(x, 'DateWrapper') || isa(x, 'datetime'));
    parser.addParameter('Text', cell.empty(1, 0), @(x) ischar(x) || isa(x, 'string') || iscellstr(x(1:2:end)));
    parser.addParameter('ExcludeFromLegend', true, @(x) isequal(x, true) || isequal(x, false) );
    parser.addParameter({'Placement', 'LinePlacement', 'TimePosition'}, 'Exactly', @(x) any(strcmpi(x, {'Exactly', 'Middle', 'Before', 'After'})));
    parser.addParameter('NumPointsWithin', 5);
    % Legacy options
    parser.addParameter('Caption', cell.empty(1, 0), @(x) ischar(x) || iscellstr(x(1:2:end)));
    parser.addParameter('VPosition', '');
    parser.addParameter('HPosition', '');
end
parse(parser, axesHandle, caller, location, varargin{:});
opt = parser.Options;
unmatched = parser.UnmatchedInCell;
usingDefaults = parser.UsingDefaultsInStruct;

if isequal(axesHandle, @gca)
    axesHandle = gca( );
end

% Handle shortcut syntax for Text=
if ~iscell(opt.Text) || size(opt.Text, 2)==1
    opt.Text = {'String', opt.Text};
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
    BACKGROUND_LEVEL = -3;
else
    BACKGROUND_LEVEL = -2;
end

%--------------------------------------------------------------------------

numOfAxes = numel(axesHandle);
for a = 1 : numOfAxes
    h = axesHandle(a);
    % Check for plotyy peers, and return the background axes object.
    h = grfun.mychkforpeers(h);

    % Vertical lines: If this is a time series graph, convert the vline
    % position to a date grid point.
    if isVertical
        if isa(location, 'DateWrapper')
            xLim = get(h, 'XLim');
            if isa(xLim, 'datetime')
                location = resolvePlacement( );
            else
                location = dat2dec(location, 'centre');
                freq = getappdata(h, 'IRIS_FREQ');
                if ~isempty(freq) && isnumeric(freq) && isscalar(freq) ...
                        && any(freq==[0, 1, 2, 4, 6, 12, 52])
                    dx = 0.5 / max(1, freq);
                    switch opt.Placement
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
            opt.NumPointsWithin = 5;
            xData = repmat(location(i), 1, opt.NumPointsWithin+2);
            yData = [
                yLim(1)-LIM_MULTIPLE*yHeight ...
                , linspace(yLim(1), yLim(2), opt.NumPointsWithin) ...
                , yLim(2)+LIM_MULTIPLE*yHeight ...
            ];
        else
            xData = [
                xLim(1)-LIM_MULTIPLE*xWidth ...
                , linspace(xLim(1), xLim(2), opt.NumPointsWithin) ...
                , xLim(2)+LIM_MULTIPLE*xWidth ...
            ];
            yData = repmat(location(i), 1, opt.NumPointsWithin+2);
        end
        % Function line( ) always adds line objects to existing graphs even if
        % the NextPlot option is 'replace'
        ithLineHandle = line(  ...
            xData, yData ...
            , 'Parent', h ...
            , 'Color', [0, 0, 0] ...
            , 'YLimInclude', 'off' ...
            , 'XLimInclude', 'off' ...
            , 'LineWidth', 0.5 ...
            , unmatched{:} ...
        );
        % Add annotation
        if ~isempty(opt.Text) && isVertical
            ithTextHandle ...
                = visual.backend.createCaption(h, location(i), opt.Text{:});
            textHandles = [textHandles, ithTextHandle]; %#ok<AGROW>
        end

        setappdata(ithLineHandle, 'IRIS_BackgroundLevel', BACKGROUND_LEVEL);
        lineHandles = [lineHandles, ithLineHandle]; %#ok<AGROW>
    end

    visual.backend.moveToBackground(h);
    if switchedToLeft
        yyaxis(h, 'right');
    end

    if opt.ExcludeFromLegend
        visual.excludeFromLegend(lineHandles);
    end

    if ~isempty(lineHandles)
        set( lineHandles, ...
             'Tag', caller );
    end

    if ~isempty(textHandles)
        set( textHandles, ...
             'Tag', [caller, '-caption'] );
    end
end

return




    function datetimeLocation = resolvePlacement( )
        axesPositionWithinPeriod = getappdata(h, 'IRIS_PositionWithinPeriod');
        if isempty(axesPositionWithinPeriod)
            axesPositionWithinPeriod = 'start';
        end
        datetimeLocation = dater.toMatlab(location, axesPositionWithinPeriod);
        if strcmpi(opt.Placement, 'before')
            [~, halfDuration] = duration(location);
            datetimeLocation = datetimeLocation - halfDuration;
        elseif strcmpi(opt.Placement, 'after')
            [~, halfDuration] = duration(location);
            datetimeLocation = datetimeLocation + halfDuration;
        end
    end%
end%

