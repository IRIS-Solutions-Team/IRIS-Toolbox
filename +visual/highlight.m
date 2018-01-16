function [patchHandles, textHandles] = highlight(varargin)
% highlight  Highlight specified range or date range in a graph.
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
% * `'Text='` [ cellstr | char | string ] - Annotate the highlighted area
% with a text string.
%
% * `'Color='` [ numeric | *`0.8`* ] - An RGB color code, a Matlab color
% name, or a scalar shade of gray.
%
% * `'ExcludeFromLegend='` [ *`true`* | `false` ] - Exclude the highlighted
% area from legend.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

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

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('visual.highlight');
    INPUT_PARSER.KeepUnmatched = true;
    INPUT_PARSER.addRequired('Axes', @(x) isequal(x, @gca) || all(isgraphics(x, 'Axes')));
    INPUT_PARSER.addRequired('Range', @(x) all(cellfun(@(y) isa(y, 'DateWrapper') || isnumeric(y), x)));
    INPUT_PARSER.addParameter('Text', cell.empty(1, 0), @(x) ischar(x) || isa(x, 'string') || iscellstr(x(1:2:end)));
    INPUT_PARSER.addParameter('Color', 0.8*[1, 1, 1], @(x) (isnumeric(x) && length(x)==3) || ischar(x) || (isnumeric(x) && isscalar(x) && x>=0 && x<=1) );
    INPUT_PARSER.addParameter('DatePosition', 'start', @(x) any(strcmpi(x, {'start', 'middle', 'end'})));
    INPUT_PARSER.addParameter('ExcludeFromLegend', true, @(x) isequal(x, true) || isequal(x, false) );
    INPUT_PARSER.addParameter('Transparent', 0, @(x) isnumeric(x) && isscalar(x) && x>=0 && x<=1 );

    % Legacy options
    INPUT_PARSER.addParameter('Caption', cell.empty(1, 0), @(x) ischar(x) || isa(x, 'string') || iscellstr(x));
    INPUT_PARSER.addParameter('VPosition', '');
    INPUT_PARSER.addParameter('HPosition', '');
end
INPUT_PARSER.parse(axesHandle, range, varargin{:});
opt = INPUT_PARSER.Options;
unmatched = INPUT_PARSER.UnmatchedInCell;
usingDefaults = INPUT_PARSER.UsingDefaultsInStruct;

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

Z_DATA = -4;
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

        ithPatchHandle = drawPatch(h, xData, yData, Z_DATA, opt, unmatched);
        
        % Add caption to the highlight.
        if ~isempty(opt.Text)
            ithTextHandle = visual.backend.createCaption( ...
                h, xData([1, 2]), opt.Text{:} ...
            );
            textHandles = [textHandles, ithTextHandle];
        end
        
        % Make sure zLim includes zCoor.
        zLim = get(h, 'zLim');
        zLim(1) = min(zLim(1), Z_DATA);
        zLim(2) = max(zLim(2), 0);
        set(h, 'zLim', zLim);

        setappdata(ithPatchHandle, 'IRIS_BackgroundLevel', Z_DATA);
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

end


function xData = getXData(h, range, opt)
    if isa(range, 'DateWrapper')
        freq = DateWrapper.getFrequencyFromNumeric(range(1));
        xLim = get(h, 'XLim');
        if isa(xLim, 'datetime')
            switch lower(opt.DatePosition)
            case 'start'
                xData = [datetime(range(1)-1, 'middle'), datetime(range(end), 'middle')];
            case 'middle'
                xData = [datetime(range(1), 'start'), datetime(range(end), 'end')];
            case 'end'
                xData = [datetime(range(1), 'middle'), datetime(range(end)+1, 'middle')];
            end
        else
            xData = dat2dec(range([1, end]), 'centre');
        end
    else
        freq = Frequency.NaF;
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
end


function yData = getYData(h, LIM_MULTIPLE)
    yData = get(h, 'YLim');
    height = yData(2) - yData(1);
    yData = [yData(1)-LIM_MULTIPLE*height, yData(2)+LIM_MULTIPLE*height];
end


function patchHandle = drawPatch(h, xData, yData, Z_DATA, opt, unmatched)
    xData = xData([1, 2, 2, 1]);
    yData = yData([1, 1, 2, 2]);
    zData = Z_DATA*ones(size(xData));    
    nextPlot = get(h, 'NextPlot');
    set(h, 'NextPlot', 'Add');
    patchHandle = fill( ...
        xData, yData, opt.Color, ...
        'ZData', zData, ...
        'Parent', h, ...
        'YLimInclude', 'off', 'XLimInclude', 'off', ...
        'EdgeColor', 'none', 'FaceAlpha', 1-opt.Transparent, ...
        unmatched{:} ...
    );
    set(h, 'NextPlot', nextPlot);
end
