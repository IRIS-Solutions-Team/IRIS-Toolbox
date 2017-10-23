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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%#ok<*AGROW>

if ~isempty(varargin{1}) && all(ishghandle(varargin{1}))
    axesHandles = varargin{1};
    varargin(1) = [ ];
else
    axesHandles = gca( );
end

range = varargin{1};
varargin(1) = [ ];

patchHandles = [ ]; % Handles to patch objects.
textHandles = [ ]; % Handles to caption objects.

if isempty(range)
    return
end

% Multiple separate ranges.
if iscell(range)
    for i = 1 : numel(range)
        [ithPatchHandle, ithTextHandle] = highlight(axesHandles, range{i}, varargin{:});
        patchHandles = [patchHandles, ithPatchHandle(:).'];
        textHandles = [textHandles, ithTextHandle(:).'];
    end
    return
end

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('visual.highlight');
    INPUT_PARSER.KeepUnmatched = true;
    INPUT_PARSER.addRequired('Axes', @(x) isa(x, 'matlab.graphics.axis.Axes'));
    INPUT_PARSER.addRequired('Range', @(x) isempty(x) || isnumeric(x));
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
INPUT_PARSER.parse(axesHandles, range, varargin{:});
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
        
if isscalar(opt.Color)
    opt.Color = opt.Color*[1, 1, 1];
end

Z_COOR = -1;
LIM_MULTIPLE = 100;

%--------------------------------------------------------------------------

if ischar(range)
    range = textinp2dat(range);
end

for iAx = axesHandles(:).'
    % Preserve the order of figure children.
    % fg = get(iAx, 'parent');
    % fgch = get(fg, 'children');
    
    % Check for plotyy peers, and return the background axes object.
    h = grfun.mychkforpeers(iAx);
    
    % Move grid to the foreground; otherwise, the upper edge of the plot box
    % will be overpainted by the highlight patch.
    set(h, 'layer', 'top');
    
    % NB: Instead of moving the grid to the foreground, we could use
    % transparent color for the highligh object (faceAlpha). This is
    % unfortunately not supported by the Painters renderer.
    
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
        continue
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

    yData = get(h, 'YLim');
    yHeight = yData(2) - yData(1);
    yData = [yData(1)-LIM_MULTIPLE*yHeight, yData(2)+LIM_MULTIPLE*yHeight];

    xData = xData([1, 2, 2, 1]);
    yData = yData([1, 1, 2, 2]);
    zData = Z_COOR*ones(size(xData));    
    nextPlot = get(h, 'NextPlot');
    set(h, 'NextPlot', 'Add');
    ithPatchHandle = fill( ...
        xData, yData, opt.Color, ...
        'ZData', zData, ...
        'Parent', h, ...
        'YLimInclude', 'off', 'XLimInclude', 'off', ...
        'EdgeColor', 'none', 'FaceAlpha', 1-opt.Transparent, ...
        unmatched{:} ...
    );
    patchHandles = [patchHandles, ithPatchHandle];

    set(h, 'NextPlot', nextPlot);
    
    % Add caption to the highlight.
    if ~isempty(opt.Text)
        ithTextHandle = visual.backend.createCaption( ...
            h, xData([1, 2]), opt.Text{:} ...
        );
        textHandles = [textHandles, ithTextHandle];
    end
    
    % Make sure zLim includes zCoor.
    zLim = get(iAx, 'zLim');
    zLim(1) = min(zLim(1), Z_COOR);
    zLim(2) = max(zLim(2), 0);
    set(iAx, 'zLim', zLim);
end

if isempty(patchHandles)
    return
end

% Tag the highlights and captions for grfun.style.
set(patchHandles, 'tag', 'highlight');
set(textHandles, 'tag', 'highlight-caption');

%{
for i = 1 : length(patchHandles)
    setappdata(patchHandles(i), 'IRIS_BACKGROUND', 'Highlight');
end
grfun.mymovetobkg(axesHandles);
%}

if opt.ExcludeFromLegend
    grfun.excludefromlegend(patchHandles);
end

end
