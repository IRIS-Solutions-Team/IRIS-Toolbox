function [handlePlot, time, yData, axesHandle, xData, unmatchedOptions] = implementPlot(plotFunc, varargin)
% implementPlot  Plot functions for TimeSubscriptable objects
%
% Backend function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

IS_ROUND = @(x) isnumeric(x) && all(x==round(x));

if isgraphics(varargin{1})
    axesHandle = varargin{1};
    varargin(1) = [ ];
else
    axesHandle = @gca;
end

if isa(varargin{1}, 'DateWrapper') || isequal(varargin{1}, Inf)
    time = varargin{1};
    varargin(1) = [ ];
elseif isnumeric(varargin{1})
    time = DateWrapper.fromDouble(varargin{1});
    varargin(1) = [ ];
else
    time = Inf;
end

this = varargin{1};
varargin(1) = [ ];

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser(['TimeSubscriptable.implementPlot(', char(plotFunc), ')']);
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('PlotFun', @validatePlotFunction);
    inputParser.addRequired('Axes', @(x) isequal(x, @gca) || (all(isgraphics(x, 'Axes')) && isscalar(x)));
    inputParser.addRequired('Dates', @(x) isa(x, 'Date') || isa(x, 'DateWrapper') || isequal(x, Inf) || isempty(x) || IS_ROUND(x) );
    inputParser.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable') && ~iscell(x.Data));
    inputParser.addOptional('SpecString', cell.empty(1, 0), @(x) iscellstr(x)  && numel(x)<=1);
    inputParser.addParameter('DateTick', @auto, @(x) isequal(x, @auto) || DateWrapper.validateDateInput(x));
    inputParser.addParameter('DateFormat', @default, @(x) isequal(x, @default) || ischar(x));
    inputParser.addParameter( 'PositionWithinPeriod', @auto, @(x) isequal(x, @auto) ...
                              || any(strncmpi(x, {'Start', 'Middle', 'End'}, 1)) );
end

inputParser.parse(plotFunc, axesHandle, time, this, varargin{:});
specString = inputParser.Results.SpecString;
opt = inputParser.Options;
unmatchedOptions = inputParser.UnmatchedInCell;

enforceXLimHere = true;
if isequal(time, Inf)
    time = this.Range;
    enforceXLimHere = false;
elseif isempty(time) || isnad(time)
    time = this.Start;
    time = time([ ], 1);
else
    time = time(:);
end

if numel(time)==1
    validFrequencies = isnan(this.Start) || validateDateOrInf(this, time);
elseif numel(time)==2
    validFrequencies = isnan(this.Start) ...
                       || (validateDateOrInf(this, time(1)) && validateDateOrInf(this, time(2)));
else
    validFrequencies = isnan(this.Start) || validateDate(this, time);
end

if ~validFrequencies
    throw( exception.Base('TimeSubscriptable:IllegalPlotRangeFrequency', 'error') )
end

%--------------------------------------------------------------------------

if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle( );
end

if numel(time)==2 && all(isinf(time))
    time = Inf;
end
[yData, time] = getData(this, time);

if ~isempty(time)
    timeFrequency = DateWrapper.getFrequency(time(1));
else
    timeFrequency = Frequency.NaF;
end

if ndims(yData)>2
    yData = yData(:, :);
end

[ xData, ...
  positionWithinPeriod, ...
  dateFormat ] = TimeSubscriptable.createDateAxisData( axesHandle, ...
                                                       time, ...
                                                       opt.PositionWithinPeriod, ...
                                                       opt.DateFormat );

if isempty(plotFunc)
    handlePlot = gobjects(0);
    return
end

if ~ishold(axesHandle)
    resetAxes( );
end

set(axesHandle, 'XLimMode', 'auto', 'XTickMode', 'auto');
handlePlot = plotFunc(axesHandle, xData, yData, specString{:}, unmatchedOptions{:});
addXLimConstraints( );
setXLim( );
setXTick( );
setXTickLabelFormat( );
set(axesHandle, 'XTickLabelRotation', 0);

setappdata(axesHandle, 'IRIS_PositionWithinPeriod', positionWithinPeriod);
setappdata(axesHandle, 'IRIS_TimeSeriesPlot', true);

return




    function addXLimConstraints( )
        if isequal(plotFunc, @bar) || isequal(plotFunc, @numeric.barcon)
            xLimConstrOld = getappdata(axesHandle, 'IRIS_XLimConstraints');
            margin = getXLimMarginCalendarDuration(timeFrequency);
            xLimConstrHere = [ xData(1)-margin
                               xData(:)+margin ];
            if isempty(xLimConstrOld)
                xLimConstrNew = xLimConstrHere;
            else
                xLimConstrNew = [ xLimConstrOld
                                  xLimConstrHere ];
            end
            xLimConstrNew = sort(unique(xLimConstrNew));
            setappdata(axesHandle, 'IRIS_XLimConstraints', xLimConstrNew);
        end
    end


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
        if ~isempty(xLimActual)
            set(axesHandle, 'XLim', xLimActual);
        end
        setappdata(axesHandle, 'IRIS_XLim', xLimNew);
        setappdata(axesHandle, 'IRIS_EnforceXLim', enforceXLimNew);
    end%


    function setXTick( )
        if isequal(opt.DateTick, @auto) || isempty(opt.DateTick)
            return
        end
        try
            dateTick = DateWrapper.toDatetime(opt.DateTick);
            set(axesHandle, 'XTick', dateTick);
        end
    end%


    function xData = setXTickLabelFormat( )
        if isempty(time) || timeFrequency==Frequency.INTEGER
            return
        end
        try
            axesHandle.XAxis.TickLabelFormat = dateFormat;
        end
    end%


    function xLim = getXLimActual(xLim)
        xLimConstr = getappdata(axesHandle, 'IRIS_XLimConstraints');
        if isempty(xLimConstr)
            return
        end
        if xLim(1)>xLimConstr(1) && xLim(1)<xLimConstr(end)
            pos = find(xLim(1)<xLimConstr, 1) - 1;
            xLim(1) = xLimConstr(pos);
        end
        if xLim(2)>xLimConstr(2) && xLim(2)<xLimConstr(end)
            pos = find(xLim(2)>xLimConstr, 1, 'last') + 1;
            xLim(2) = xLimConstr(pos);
        end
    end%


    function resetAxes( )
        list = { 'IRIS_PositionWithinPeriod'
                 'IRIS_TimeSeriesPlot'
                 'IRIS_XLim'
                 'IRIS_EnforceXLim'
                 'IRIS_XLimConstraints'
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
% Local validation functions
%

function flag = validatePlotFunction(x)
    list = { @plot, @bar, @area, @stem, @stairs, @numeric.barcon, @numeric.errorbar };
    flag = any( cellfun(@(y) isequal(x, y), list) );
end%

