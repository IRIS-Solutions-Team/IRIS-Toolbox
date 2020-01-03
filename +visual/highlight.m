function [patchHandles, textHandles] = highlight(varargin)
% highlight  Highlight specified range or date range in a graph
%
% __Syntax__
%
%     [PatchHandles, TextHandles] = highlight(Range, ...)
%     [PatchHandles, TextHandles] = highlight(AxesHandles, Range, ...)
%
%
% __Input Arguments__
%
% * `Range` [ numeric ] - X-axis range or date range that will be
% highlighted.
%
% * `AxesHandles` [ numeric ] - Handle(s) to axes object(s) in which the
% highlight will be made.
%
%
% __Output Arguments__
%
% * `PatchHandles` [ numeric ] - Handle to the highlighted area (patch object).
%
% * `TextHandles` [ numeric ] - Handle to the caption (text object).
%
%
% __Options__
%
% * `Text=''` [ cellstr | char | string ] - Annotate the highlighted area
% with a text string.
%
% * `Color=0.8` [ numeric | char ] - An RGB color code, a Matlab color
% name, or a scalar shade of gray.
%
% * `ExcludeFromLegend=true` [ `true` | `false` ] - Exclude the highlighted
% area from legend.
%
% * `HandleVisibility=false` [ `true` | `false` ] - Visibility of the
% handle to the patch object(s) created.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%#ok<*AGROW>

patchHandles = gobjects(1, 0); % Handles to patch objects.
textHandles = gobjects(1, 0); % Handles to caption objects.

if isempty(varargin)
    return
end

if isgraphics(varargin{1})
    axesHandle = varargin{1};
    varargin(1) = [ ];
    axesHandle = visual.backend.resolveAxesHandles('All', axesHandle);
else
    axesHandle = @gca;
end
    
if isempty(axesHandle) || isempty(varargin)
    return
end

range = varargin{1};
varargin(1) = [ ];

if isempty(range)
    return
elseif ~iscell(range)
    range = { range };
end
for i = 1 : numel(range)
    if ischar(range{i})
        range{i} = textinp2dat(range{i});
    end
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('visual.highlight');
    parser.KeepUnmatched = true;
    parser.addRequired('Axes', @(x) isequal(x, @gca) || all(isgraphics(x, 'Axes')));
    parser.addRequired('Range', @(x) all(cellfun(@(y) isa(y, 'DateWrapper') || isnumeric(y), x)));

    parser.addParameter('Alpha', 1, @(x) validate.numericScalar(x, [0, 1]));
    parser.addParameter('Color', 0.8*[1, 1, 1], @(x) (isnumeric(x) && length(x)==3) || ischar(x) || (isnumeric(x) && isscalar(x) && x>=0 && x<=1) );
    parser.addParameter('DatePosition', 'start', @(x) any(strcmpi(x, {'start', 'middle', 'end'})));
    parser.addParameter('ExcludeFromLegend', true, @(x) isequal(x, true) || isequal(x, false) );
    parser.addParameter('HandleVisibility', 'Off', @(x) validate.logicalScalar(x) || validate.anyString(x, 'On', 'Off'));
    parser.addParameter('Text', cell.empty(1, 0), @(x) ischar(x) || isa(x, 'string') || iscellstr(x(1:2:end)));

    % Legacy options
    parser.addParameter('Caption', cell.empty(1, 0), @(x) ischar(x) || isa(x, 'string') || iscellstr(x));
    parser.addParameter('VPosition', '');
    parser.addParameter('HPosition', '');
end
parser.parse(axesHandle, range, varargin{:});
opt = parser.Options;
unmatched = parser.UnmatchedInCell;
usingDefaults = parser.UsingDefaultsInStruct;

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
        
if isscalar(opt.Color)
    opt.Color = opt.Color*[1, 1, 1];
end

BACKGROUND_LEVEL = -4;
LIM_MULTIPLE = 100;

%--------------------------------------------------------------------------

for a = 1 : numel(axesHandle)
    h = axesHandle(a);
    % Legacy test for plotyy
    h = grfun.mychkforpeers(h);

    if isnumeric(h)
        % Handle to axes can be a numeric which passes the isgraphics
        % test but cannot be called with yyaxis. Convert to graphics here.
        h = visual.backend.numericToHandle(h);
    end

    % Switch to left y-axis if needed
    switchedToLeft = visual.backend.switchToLeft(h);

    % Move grid to the foreground; otherwise, the upper edge of the plot box
    % will be overpainted by the highlight patch.
    set(h, 'layer', 'top');

    yData = getYData(h, LIM_MULTIPLE);
    for i = 1 : numel(range)
        xData = getXData(h, range{i}, opt);
        if isempty(xData)
            continue
        end

        ithPatchHandle = drawPatch(h, xData, yData, opt, unmatched);
        
        % Add caption to the highlight.
        if ~isempty(opt.Text)
            ithTextHandle = visual.backend.createCaption(h, xData([1, 2]), opt.Text{:});
            textHandles = [textHandles, ithTextHandle];
        end
        
        setappdata(ithPatchHandle, 'IRIS_BackgroundLevel', BACKGROUND_LEVEL);
        patchHandles = [patchHandles, ithPatchHandle];
    end

    % Tag the highlights and captions for styling
    set(patchHandles, 'tag', 'highlight');
    set(textHandles, 'tag', 'highlight-caption');

    visual.backend.moveToBackground(h);
    if switchedToLeft
        yyaxis(h, 'right');
    end

    if opt.ExcludeFromLegend
        visual.excludeFromLegend(patchHandles);
    end
end

%{
if isequal(opt.HandleVisibility, true)
    opt.HandleVisibility = 'On';
elseif isequal(opt.HandleVisibility, false)
    opt.HandleVisibility = 'Off';
end
set(patchHandles, 'HandleVisibility', opt.HandleVisibility);
%}

end%




function xData = getXData(h, range, opt)
    if isa(range, 'DateWrapper')
        startOfRange = double( getFirst(range) );
        endOfRange = double( getLast(range) );
        freq = DateWrapper.getFrequencyAsNumeric(startOfRange);
        xLim = get(h, 'XLim');
        if isa(xLim, 'datetime')
            switch lower(opt.DatePosition)
                case 'start'
                    xData = [ DateWrapper.toDatetime(startOfRange-1, 'middle'), ...
                              DateWrapper.toDatetime(endOfRange, 'middle') ];
                case 'middle'
                    xData = [ DateWrapper.toDatetime(startOfRange, 'start'), ...
                              DateWrapper.toDatetime(endOfRange, 'end') ];
                case 'end'
                    xData = [ DateWrapper.toDatetime(startOfRange, 'middle'), ...
                              DateWrapper.toDatetime(endOfRange+1, 'middle') ];
            end
        else
            xData = [ dat2dec(startOfRange, 'centre'), ...
                      dat2dec(endOfRange, 'centre') ];
        end
    else
        freq = NaN;
        xData = range([1, end]);
    end
    if isempty(xData)
        return
    end
    if isnumeric(xData)
        around = 0.5;
        if isequal(getappdata(h, 'IRIS_SERIES'), true)
            if any(freq==[2, 4, 6, 12])
                around = around / freq;
            end
        end
        xData = [xData(1)-around, xData(2)+around];
    end
end%




function yData = getYData(h, LIM_MULTIPLE)
    yData = get(h, 'YLim');
    height = yData(2) - yData(1);
    yData = [yData(1)-LIM_MULTIPLE*height, yData(2)+LIM_MULTIPLE*height];
end%




function handlePatch = drawPatch(handleAxes, xData, yData, opt, unmatched)
    xData = xData([1, 2, 2, 1]);
    yData = yData([1, 1, 2, 2]);
    nextPlot = get(handleAxes, 'NextPlot');
    set(handleAxes, 'NextPlot', 'Add');
    handlePatch = fill( xData, yData, opt.Color, ...
                        'Parent', handleAxes, ...
                        'YLimInclude', 'off', 'XLimInclude', 'off', ...
                        'EdgeColor', 'none', 'FaceAlpha', opt.Alpha, ...
                        unmatched{:} );
    set(handleAxes, 'NextPlot', nextPlot);
end%

