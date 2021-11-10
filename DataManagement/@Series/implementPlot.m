% implementPlot  Plot functions for Series objects
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function [ ...
    plotHandle, dates, yData, ...
    axesHandle, xData, ...
    unmatchedOptions ...
] = implementPlot(plotFunc, varargin)

[axesHandle, dates, this, plotSpec, varargin] = ...
    NumericTimeSubscriptable.preparePlot(varargin{:});

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('Series.implementPlot');
    pp.KeepUnmatched = true;
    pp.addParameter('DateTick', @auto, @(x) isequal(x, @auto) || validate.date(x));
    pp.addParameter('DateFormat', @default, @(x) isequal(x, @default) || isstring(x) || ischar(x) || iscellstr(x));
    pp.addParameter( 'PositionWithinPeriod', @auto, @(x) isequal(x, @auto) ...
                         || any(strncmpi(x, {'Start', 'Middle', 'End'}, 1)) );
    pp.addParameter('XLimMargins', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    pp.addParameter('Smooth', false, @validate.logicalScalar);
    pp.addParameter('Highlight', [], @validate.properRange);
end
opt = pp.parse(varargin{:});
unmatchedOptions = pp.UnmatchedInCell;
%)


dates = reshape(double(dates), 1, []);
enforceXLimHere = true;
if isequal(dates, Inf) || isequal(dates, [-Inf, Inf])
    dates = reshape(this.RangeAsNumeric, 1, []);
    enforceXLimHere = false;
elseif isempty(dates) || all(isnan(dates))
    dates = double.empty(0, 1);
else
    dates = reshape(dates, 1, []);
    locallyCheckUserFrequency(this, dates);
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

[xData, positionWithinPeriod, dateFormat] ...
    = TimeSubscriptable.createDateAxisData(axesHandle, dates, opt.PositionWithinPeriod, opt.DateFormat);

if isempty(plotFunc)
    plotHandle = gobjects(0);
    return
end

if ~ishold(axesHandle)
    hereResetAxes( );
end

set(axesHandle, 'XLimMode', 'auto', 'XTickMode', 'auto');
[plotHandle, isTimeAxis] = this.plotSwitchboard( ...
    plotFunc, axesHandle, xData, yData, plotSpec, opt.Smooth, unmatchedOptions{:} ...
);

try %#ok<TRYNC>
    axesHandle.XAxis.TickLabelFormat = char(dateFormat);
end

if isTimeAxis && ~isempty(xData)
    hereAddXLimMargins( );
    hereSetXLim( );
    hereSetXTick( );
    hereSetXTickLabelFormat( );

    set(axesHandle, 'XTickLabelRotation', 0);
    setappdata(axesHandle, 'IRIS_PositionWithinPeriod', positionWithinPeriod);
    setappdata(axesHandle, 'IRIS_TimeSeriesPlot', true);
end

locallyAfter(axesHandle, opt);

return

    function hereAddXLimMargins( )
        % Leave a half period on either side of the horizontal axis around
        % the currently added data
        %(
        if isequal(opt.XLimMargins, false)
            return
        end
        if isequal(opt.XLimMargins, @auto) ...
           && ~(isequal(plotFunc, @bar) || isequal(plotFunc, @numeric.barcon))
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


    function hereSetXLim( )
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
        xLimActual = hereGetXLimActual(xLimNew);
        if enforceXLimHere && ~isempty(xLimActual)
            try
                set(axesHandle, 'XLim', xLimActual);
            end
        end
        setappdata(axesHandle, 'IRIS_XLim', xLimNew);
        setappdata(axesHandle, 'IRIS_EnforceXLim', enforceXLimNew);
        %)
    end%


    function hereSetXTick( )
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


    function hereSetXTickLabelFormat( )
        %(
        if isempty(dates) || timeFrequency==Frequency.INTEGER
            return
        end
        try
            axesHandle.XAxis.TickLabelFormat = dateFormat;
        end
        %)
    end%


    function xLim = hereGetXLimActual(xLim)
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


    function hereResetAxes( )
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

function locallyAfter(axesHandle, opt);
    %(
    if ~isempty(opt.Highlight)
        visual.highlight(axesHandle, opt.Highlight);
    end
    %)
end%

%
% Local validation functions
%

function locallyCheckUserFrequency(this, dates)
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
