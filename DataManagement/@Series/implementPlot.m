function [ plotHandle, dates, yData, ...
           axesHandle, xData, ...
           unmatchedOptions ] = implementPlot(plotFunc, varargin)
% implementPlot  Plot functions for Series objects
%
% Backend function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

[axesHandle, dates, this, plotSpec, varargin] = ...
    NumericTimeSubscriptable.preparePlot(varargin{:});

persistent parser
if isempty(parser)
    parser = extend.InputParser('Series.implementPlot');
    parser.KeepUnmatched = true;
    parser.addParameter('DateTick', @auto, @(x) isequal(x, @auto) || DateWrapper.validateDateInput(x));
    parser.addParameter('DateFormat', @default, @(x) isequal(x, @default) || ischar(x));
    parser.addParameter( 'PositionWithinPeriod', @auto, @(x) isequal(x, @auto) ...
                         || any(strncmpi(x, {'Start', 'Middle', 'End'}, 1)) );
    parser.addParameter('XLimMargins', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
    parser.addParameter('Smooth', false, @validate.logicalScalar);
end
parser.parse(varargin{:});
opt = parser.Options;
unmatchedOptions = parser.UnmatchedInCell;

dates = double(dates);
enforceXLimHere = true;
if isequal(dates, Inf) || isequal(dates, [-Inf, Inf])
    dates = this.RangeAsNumeric;
    enforceXLimHere = false;
elseif isempty(dates) || all(isnan(dates))
    dates = double.empty(0, 1);
else
    dates = dates(:);
    checkUserFrequency(this, dates);
end

%--------------------------------------------------------------------------

[yData, dates] = getData(this, dates);

if ~isempty(dates)
    timeFrequency = dater.getFrequency(dates(1));
else
    timeFrequency = NaN;
end

if ndims(yData)>2
    yData = yData(:, :);
end

[ xData, ...
  positionWithinPeriod, ...
  dateFormat ] = TimeSubscriptable.createDateAxisData( axesHandle, ...
                                                       dates, ...
                                                       opt.PositionWithinPeriod, ...
                                                       opt.DateFormat );

if isempty(plotFunc)
    plotHandle = gobjects(0);
    return
end

if ~ishold(axesHandle)
    resetAxes( );
end

set(axesHandle, 'XLimMode', 'auto', 'XTickMode', 'auto');
[plotHandle, isTimeAxis] = this.plotSwitchboard( plotFunc, ...
                                                 axesHandle, ...
                                                 xData, ...
                                                 yData, ...
                                                 plotSpec, ...
                                                 opt.Smooth, ...
                                                 unmatchedOptions{:} );
if isTimeAxis
    addXLimMargins( );
    setXLim( );
    setXTick( );
    setXTickLabelFormat( );
    set(axesHandle, 'XTickLabelRotation', 0);
    setappdata(axesHandle, 'IRIS_PositionWithinPeriod', positionWithinPeriod);
    setappdata(axesHandle, 'IRIS_TimeSeriesPlot', true);
end

return




    function addXLimMargins( )
        % Leave a half period on either side of the horizontal axis around
        % the currently added data
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
    end%




    function setXLim( )
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
        xLimActual = getXLimActual(xLimNew);
        if enforceXLimHere && ~isempty(xLimActual)
            try
                set(axesHandle, 'XLim', xLimActual);
            end
        end
        setappdata(axesHandle, 'IRIS_XLim', xLimNew);
        setappdata(axesHandle, 'IRIS_EnforceXLim', enforceXLimNew);
    end%




    function setXTick( )
        if isequal(opt.DateTick, @auto) || isempty(opt.DateTick)
            return
        end
        try
            dateTick = dater.toMatlab(opt.DateTick);
            set(axesHandle, 'XTick', dateTick);
        end
    end%




    function setXTickLabelFormat( )
        if isempty(dates) || timeFrequency==Frequency.INTEGER
            return
        end
        try
            axesHandle.XAxis.TickLabelFormat = dateFormat;
        end
    end%




    function xLim = getXLimActual(xLim)
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
    end%




    function resetAxes( )
        list = { 'IRIS_PositionWithinPeriod'
                 'IRIS_TimeSeriesPlot'
                 'IRIS_XLim'
                 'IRIS_EnforceXLim'
                 'IRIS_XLimMargins'
                 'IRIS_XLim'
                 'IRIS_XLim' };
        for i = 1 : numel(list)
            try
                rmappdata(axesHandle, list{i});
            end
        end
    end%
end%

%
% Local Validation Functions
%


function checkUserFrequency(this, dates)
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
end%

