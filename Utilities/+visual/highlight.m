
function varargout = highlight(varargin)

    BACKGROUND_LEVEL = -4;
    LIM_MULTIPLE = 100;

    %#ok<*AGROW>

    patchHandles = gobjects(1, 0); % Handles to patch objects
    textHandles = gobjects(1, 0); % Handles to caption objects

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

    persistent ip
    if isempty(ip)
        ip = extend.InputParser('visual.highlight');
        ip.KeepUnmatched = true;
        addRequired(ip, 'Axes', @(x) isequal(x, @gca) || all(isgraphics(x, 'Axes')));
        addRequired(ip, 'Range', @(x) all(cellfun(@validate.date, x)));

        addParameter(ip, 'Alpha', 1, @(x) validate.numericScalar(x, [0, 1]));
        addParameter(ip, 'Color', 0.8*[1, 1, 1], @(x) (isnumeric(x) && length(x)==3) || ischar(x) || (isnumeric(x) && isscalar(x) && x>=0 && x<=1) );
        addParameter(ip, 'DatePosition', 'start', @(x) any(strcmpi(x, {'start', 'middle', 'end'})));
        addParameter(ip, 'ExcludeFromLegend', true, @(x) isequal(x, true) || isequal(x, false) );
        addParameter(ip, 'HandleVisibility', 'off', @(x) validate.logicalScalar(x) || validate.anyString(x, 'on', 'off'));
        addParameter(ip, 'Text', cell.empty(1, 0), @(x) ischar(x) || isa(x, 'string') || iscellstr(x(1:2:end)));
        addParameter(ip, 'Dates', true, @validate.logicalScalar);
        addParameter(ip, 'Axis', "x", @(x) strcmpi(x, "x") || strcmpi(x, "y"));

        %
        % Legacy options
        %
        addParameter(ip, 'Caption', cell.empty(1, 0), @(x) ischar(x) || isa(x, 'string') || iscellstr(x));
        addParameter(ip, 'VPosition', '');
        addParameter(ip, 'HPosition', '');
    end
    parse(ip, axesHandle, range, varargin{:});
    opt = ip.Options;
    unmatched = ip.UnmatchedInCell;
    usingDefaults = ip.UsingDefaultsInStruct;

    if isequal(axesHandle, @gca)
        axesHandle = gca( );
    end

    % Handle shortcut syntax for Text=
    if ~iscell(opt.Text) || size(opt.Text, 2)==1
        opt.Text = {'string', opt.Text};
    end

    % Handle legacy options VPosition= and HPosition=
    if ~usingDefaults.Caption
        opt.Text = {'string', opt.Caption};
        if ~usingDefaults.VPosition
            opt.Text = [opt.Text, {'verticalPosition', opt.VPosition}];
        end
        if ~usingDefaults.HPosition
            opt.Text = [opt.Text, {'horizontalPosition', opt.HPosition}];
        end
    end

    if isscalar(opt.Color)
        opt.Color = opt.Color*[1, 1, 1];
    end

    for a = 1 : numel(axesHandle)
        h = axesHandle(a);

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

        if lower(opt.Axis)=="x"
            xData = [];
            yData = local_getYDataInf(h, LIM_MULTIPLE);
        else
            xData = local_getXDataInf(h, LIM_MULTIPLE);
            yData = [];
        end

        for i = 1 : numel(range)
            if lower(opt.Axis)=="x"
                xData = local_getXData(h, range{i}, opt);
                if isempty(xData)
                    continue
                end
            else
                yData = local_getYData(h, range{i}, opt);
                if isempty(yData)
                    continue
                end
            end

            ithPatchHandle = local_drawPatch(h, xData, yData, opt, unmatched);

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

    varargout = cell.empty(1, 0);
    if nargout>0
        varargout = {patchHandles, textHandles};
    end

end%


function xData = local_getXData(h, range, opt)
    %(
    isLegacyTimeSeriesPlot = isequal(getappdata(h, 'IRIS_SERIES'), true);
    if isLegacyTimeSeriesPlot
        datePosition = getappdata(h, 'IRIS_DATE_POSITION');
        if isempty(datePosition)
            datePosition = opt.DatePosition;
        end
        range = double(range);
        dates = [range(1)-1, range(1), range(end), range(end)+1];
        freq = dater.getFrequency(range(1));
        if freq~=Frequency.Daily
            dates = dat2dec(dates, char(datePosition));
        end
        xData = [ mean(dates(1:2)), mean(dates(3:4)) ];
        return
    end

    isTimeSeriesPlot = isequal(getappdata(h, 'IRIS_TimeSeriesPlot'), true);
    if ~isTimeSeriesPlot || ~opt.Dates
        xData = range([1, end]);
        return
    end

    range = double(range);
    startRange = range(1);
    endRange = range(end);
    freq = dater.getFrequency(startRange);
    xLim = get(h, 'XLim');
    if isa(xLim, 'datetime')
        switch lower(opt.DatePosition)
            case 'start'
                xData = [ dater.toMatlab(startRange-1, 'middle'), ...
                          dater.toMatlab(endRange, 'middle') ];
            case 'middle'
                xData = [ dater.toMatlab(startRange, 'start'), ...
                          dater.toMatlab(endRange, 'end') ];
            case 'end'
                xData = [ dater.toMatlab(startRange, 'middle'), ...
                          dater.toMatlab(endRange+1, 'middle') ];
        end
    else
        xData = [ dat2dec(startRange, 'centre'), ...
                  dat2dec(endRange, 'centre') ];
    end

    if ~isempty(xData)
        around = 0.5;
        if isequal(isTimeSeriesPlot, true)
            if any(freq==[2, 4, 6, 12])
                around = around / freq;
            end
        end
        xData = [xData(1)-around, xData(2)+around];
    end
    %)
end%


function yData = local_getYData(h, range, ~)
    %(
    yData = [range(1), range(end)];
    %)
end%


function xData = local_getXDataInf(h, LIM_MULTIPLE)
    %(
    xData = get(h, 'xLim');
    xData = [xData(1)-LIM_MULTIPLE*365, xData(2)+LIM_MULTIPLE*365];
    %)
end%


function yData = local_getYDataInf(h, LIM_MULTIPLE)
    %(
    yData = get(h, 'yLim');
    height = yData(2) - yData(1);
    yData = [yData(1)-LIM_MULTIPLE*height, yData(2)+LIM_MULTIPLE*height];
    %)
end%


function handlePatch = local_drawPatch(handleAxes, xData, yData, opt, unmatched)
    %(
    xData = xData([1, 2, 2, 1]);
    yData = yData([1, 1, 2, 2]);
    nextPlot = get(handleAxes, 'NextPlot');
    set(handleAxes, 'NextPlot', 'Add');
    handlePatch = fill( ...
        xData, yData, opt.Color ...
        , 'Parent', handleAxes ...
        , 'YLimInclude', 'off', 'XLimInclude', 'off' ...
        , 'EdgeColor', 'none', 'FaceAlpha', opt.Alpha ...
        , unmatched{:} ...
    );
    set(handleAxes, 'NextPlot', nextPlot);
    %)
end%

