
function varargout = implementPlot(plotFunc, varargin)

[axesHandle, dates, this, plotSpec, varargin] = Series.preparePlot(varargin{:});

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    ip.KeepUnmatched = true;
    addParameter(ip, 'DateTick', @auto, @(x) isequal(x, @auto) || validate.date(x));
    addParameter(ip, 'DateFormat', @auto, @(x) isequal(x, @auto) || isstring(x) || ischar(x) || iscellstr(x));
    addParameter(ip, 'PositionWithinPeriod', @auto, @(x) isequal(x, @auto) || any(strncmpi(x, {'start', 'middle', 'end'}, 1)) );
    addParameter(ip, 'Multifrequency', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'XLimMargins', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    addParameter(ip, 'Smooth', false, @validate.logicalScalar);
    addParameter(ip, 'Highlight', [], @validate.properRange);
    addParameter(ip, 'PlotSettings', cell.empty(1, 0), @iscell);
end
opt = parse(ip, varargin{:});
unmatchedOptions = ip.UnmatchedInCell;

dates = reshape(double(dates), 1, []);
enforceXLimHere = true;
if isequal(dates, Inf) || isequal(dates, [-Inf, Inf])
    dates = reshape(this.RangeAsNumeric, 1, []);
    enforceXLimHere = false;
elseif isempty(dates) || all(isnan(dates))
    dates = double.empty(0, 1);
else
    dates = reshape(dates, 1, []);
    local_checkUserFrequency(this, dates);
end

%--------------------------------------------------------------------------

[yData, dates] = getData(this, dates);

if ~isempty(dates)
    timeFrequency = dater.getFrequency(dates(1));
else
    timeFrequency = NaN;
end

if ndims(yData)>2 %#ok<ISMAT>
    yData = yData(:, :);
end

if opt.Multifrequency && isequal(opt.PositionWithinPeriod, @auto)
    opt.PositionWithinPeriod = "middle";
end

[xData, positionWithinPeriod, dateFormat] ...
    = Series.createDateAxisData(axesHandle, dates, opt.PositionWithinPeriod, opt.DateFormat);


plotHandle = gobjects(0);
if ~isempty(plotFunc)
    if ~ishold(axesHandle)
        here_resetAxes( );
    end

    set(axesHandle, 'XLimMode', 'auto', 'XTickMode', 'auto');
    [plotHandle, isTimeAxis] = this.plotSwitchboard( ...
        plotFunc, axesHandle, xData, yData, plotSpec, opt.Smooth, unmatchedOptions{:}, opt.PlotSettings{:} ...
    );

    try %#ok<TRYNC>
        axesHandle.XAxis.TickLabelFormat = char(dateFormat);
    end

    if isTimeAxis && ~isempty(xData)
        here_addXLimMargins( );
        here_setXLim( );
        here_setXTick( );
        here_setXTickLabelFormat( );

        set(axesHandle, 'XTickLabelRotation', 0);
        setappdata(axesHandle, 'IRIS_PositionWithinPeriod', positionWithinPeriod);
        setappdata(axesHandle, 'IRIS_TimeSeriesPlot', true);
    end

    local_after(axesHandle, opt);
end

varargout = { 
    plotHandle, dates, yData, ...
    xData, axesHandle, ...
    unmatchedOptions
};

varargout = varargout(1:nargout);

return

    function here_addXLimMargins( )
        % Leave a half period on either side of the horizontal axis around
        % the currently added data
        %(
        if isequal(opt.XLimMargins, false)
            return
        end
        if isequal(opt.XLimMargins, @auto) ...
           && ~(isequal(plotFunc, @bar) || isequal(plotFunc, @series.barcon))
           return
        end
        xLimMarginsOld = getappdata(axesHandle, 'IRIS_XLimMargins');
        margin = Frequency.getXLimMarginCalendarDuration(timeFrequency);
        xLimMarginsHere = [ xData(1)-margin
                            xData(:)+margin ];
        if isempty(xLimMarginsOld)
            xLimMarginsNew = xLimMarginsHere;
        else
            xLimMarginsNew = [ xLimMarginsOld
                              xLimMarginsHere ];
        end
        xLimMarginsNew = sort(unique(xLimMarginsNew));
        setappdata(axesHandle, 'IRIS_XLimMargins', xLimMarginsNew);
        %)
    end%


    function here_setXLim( )
        %(
        xLimHere = [min(xData), max(xData)];
        xLimOld = getappdata(axesHandle, 'IRIS_XLim');
        enforceXLimOld = getappdata(axesHandle, 'IRIS_EnforceXLim');
        if ~islogical(enforceXLimOld)
            enforceXLimOld = false;
        end
        enforceXLimNew = enforceXLimOld || enforceXLimHere;
        if ~enforceXLimNew
            if isempty(xLimOld)
                xLimNew = xLimHere;
            else
                xLimNew = [ min(xLimHere(1), xLimOld(1)), max(xLimHere(2), xLimOld(2)) ];
            end
        elseif enforceXLimHere
            xLimNew = xLimHere;
        else
            xLimNew = xLimOld;
        end
        xLimActual = here_getXLimActual(xLimNew);
        if enforceXLimHere && ~isempty(xLimActual)
            try
                set(axesHandle, 'XLim', xLimActual);
            end
        end
        setappdata(axesHandle, 'IRIS_XLim', xLimNew);
        setappdata(axesHandle, 'IRIS_EnforceXLim', enforceXLimNew);
        %)
    end%


    function here_setXTick( )
        %(
        if isequal(opt.DateTick, @auto) || isempty(opt.DateTick)
            return
        end
        try
            dateTick = dater.toMatlab(opt.DateTick);
            set(axesHandle, 'XTick', dateTick);
        end
        %)
    end%


    function here_setXTickLabelFormat( )
        %(
        if isempty(dates) || timeFrequency==Frequency.INTEGER
            return
        end
        try
            axesHandle.XAxis.TickLabelFormat = dateFormat;
        end
        %)
    end%


    function xLim = here_getXLimActual(xLim)
        %(
        xLimMargins = getappdata(axesHandle, 'IRIS_XLimMargins');
        if isempty(xLimMargins)
            return
        end
        if xLim(1)>xLimMargins(1) && xLim(1)<xLimMargins(end)
            pos = find(xLim(1)<xLimMargins, 1) - 1;
            xLim(1) = xLimMargins(pos);
        end
        if xLim(2)>xLimMargins(2) && xLim(2)<xLimMargins(end)
            pos = find(xLim(2)>xLimMargins, 1, 'last') + 1;
            xLim(2) = xLimMargins(pos);
        end
        %)
    end%


    function here_resetAxes( )
        %(
        list = [
            "IRIS_PositionWithinPeriod"
            "IRIS_TimeSeriesPlot"
            "IRIS_XLim"
            "IRIS_EnforceXLim"
            "IRIS_XLimMargins"
            "IRIS_XLim"
            "IRIS_XLim" 
        ];
        for n = reshape(list, 1, [])
            try %#ok<TRYNC>
                rmappdata(axesHandle, n);
            end
        end
        %)
    end%
end%

%
% Local functions
%

function local_after(axesHandle, opt);
    %(
    if ~isempty(opt.Highlight)
        visual.highlight(axesHandle, opt.Highlight);
    end
    %)
end%

%
% Local validation functions
%

function local_checkUserFrequency(this, dates)
    %(
    if numel(dates)==1 || numel(dates)==2
        validFrequencies = isnan(this.Start) || all(validateFrequencyOrInf(this, dates));
    else
        validFrequencies = isnan(this.Start) || all(validateFrequency(this, dates));
    end

    if ~validFrequencies
        THIS_ERROR = { 'Series:InvalidPlotRangeFrequency'
                       'Plot range and input dates series must have the same date frequency' };
        throw( exception.Base(THIS_ERROR, 'error') );
    end
    %)
end%




%
% Unit tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Series/implementPlotUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);


%% Test empty with no range

x = Series(qq(2020,1), rand(40,2));
y = Series();

figureHandle = figure("visible", false);
plot(x);
hold on
plot(y);
a = gca();
assertEqual(testCase, numel(a.Children), 2);
close(figureHandle);


%% Test empty with range

x = Series(qq(2020,1), rand(40,2));
y = Series();

figureHandle = figure("visible", false);
plot(x);
hold on
plot(x.Range, y);
a = gca();
assertEqual(testCase, numel(a.Children), 3);
close(figureHandle);

##### SOURCE END #####
%}

