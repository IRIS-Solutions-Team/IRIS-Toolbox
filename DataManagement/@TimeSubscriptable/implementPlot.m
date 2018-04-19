function [handlePlot, time, yData] = implementPlot(plotFunc, varargin)
% implementPlot  Plot functions for TimeSubscriptable objects
%
% Backend function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

IS_ROUND = @(x) isnumeric(x) && all(x==round(x));

if isgraphics(varargin{1})
    handleAxes = varargin{1};
    varargin(1) = [ ];
else
    handleAxes = @gca;
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
    inputParser.addRequired('PlotFun', @(x) isequal(x, @plot) || isequal(x, @bar) || isequal(x, @area) || isequal(x, @stem) || isequal(x, @numeric.barcon) || isequal(x, @numeric.errorbar));
    inputParser.addRequired('Axes', @(x) isequal(x, @gca) || (all(isgraphics(x, 'Axes')) && isscalar(x)));
    inputParser.addRequired('Time', @(x) isa(x, 'Date') || isa(x, 'DateWrapper') || isequal(x, Inf) || isempty(x) || IS_ROUND(x));
    inputParser.addRequired('Series', @(x) isa(x, 'TimeSubscriptable') && ~iscell(x.Data));
    inputParser.addOptional('SpecString', cell.empty(1, 0), @(x) iscellstr(x)  && numel(x)<=1);
    inputParser.addParameter('DateFormat', @default, @(x) isequal(x, @default) || ischar(x));
    inputParser.addParameter('PositionWithinPeriod', @auto, @(x) isequal(x, @auto) ||  any(strncmpi(x, {'Start', 'Middle', 'End'}, 1)));
end

inputParser.parse(plotFunc, handleAxes, time, this, varargin{:});
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

validFrequencies = isnan(this.Start) || validateDate(this, time);
if ~validFrequencies
    throw(exception.Base( ...
        { 'TimeSubscriptable:implementPlot:IllegalDate'
          'Plot range and input time series need to have the same date frequency.' } ...
    ));
end

%--------------------------------------------------------------------------

if isa(handleAxes, 'function_handle')
    handleAxes = handleAxes( );
end

[yData, time] = getData(this, time);
if ~isempty(time)
    timeFrequency = getFrequency(time(1));
else
    timeFrequency = Frequency.NaF;
end

if ndims(yData)>2
    yData = yData(:, :);
end

positionWithinPeriod = resolvePositionWithinPeriod( );
xData = createDateAxisData( );

if ~ishold(handleAxes)
    resetAxes( );
end

set(handleAxes, 'XLimMode', 'auto', 'XTickMode', 'auto');
handlePlot = plotFunc(handleAxes, xData, yData, specString{:}, unmatchedOptions{:});
addXLimConstraints( );
setXLim( );
setXTickLabelFormat( );
set(handleAxes, 'XTickLabelRotation', 0);

setappdata(handleAxes, 'IRIS_PositionWithinPeriod', positionWithinPeriod);
setappdata(handleAxes, 'IRIS_TimeSeriesPlot', true);

return


    function positionWithinPeriod = resolvePositionWithinPeriod( )
        axesPositionWithinPeriod = getappdata(handleAxes, 'IRIS_PositionWithinPeriod');
        positionWithinPeriod = opt.PositionWithinPeriod;
        if isempty(axesPositionWithinPeriod) 
            if isequal(positionWithinPeriod, @auto)
                positionWithinPeriod = 'Start';
            end
        else
            if isequal(positionWithinPeriod, @auto)
                positionWithinPeriod = axesPositionWithinPeriod;
            elseif ~isequal(axesPositionWithinPeriod, positionWithinPeriod)
                warning( ...
                    'TimeSubscriptable:implementPlot:DifferentPositionWithinPeriod', ...
                    'Option PositionWithinPeriod= differs from the value set in the current Axes.' ...
                );
            end
        end
    end%


    function xData = createDateAxisData( )
        if isempty(time)
            xData = datetime.empty(size(time));
            return
        end
        if timeFrequency==Frequency.INTEGER
            xData = getSerial(time);
        else
            xData = datetime(time, lower(positionWithinPeriod));
            if isequal(opt.DateFormat, @config) || isequal(opt.DateFormat, @default)
                temp = iris.get('PlotDateTimeFormat');
                opt.DateFormat = temp.(char(timeFrequency));
            end
            xData.Format = opt.DateFormat;
            try
                handleAxes.XAxis.TickLabelFormat = opt.DateFormat;
            end
        end
    end%


    function addXLimConstraints( )
        if isequal(plotFunc, @bar) || isequal(plotFunc, @numeric.barcon)
            xLimConstrOld = getappdata(handleAxes, 'IRIS_XLimConstraints');
            margin = getXLimMarginCalendarDuration(timeFrequency);
            xLimConstrHere = [
                xData(1)-margin
                xData(:)+margin
            ];
            if isempty(xLimConstrOld)
                xLimConstrNew = xLimConstrHere;
            else
                xLimConstrNew = [
                    xLimConstrOld
                    xLimConstrHere
                ];
            end
            xLimConstrNew = sort(unique(xLimConstrNew));
            setappdata(handleAxes, 'IRIS_XLimConstraints', xLimConstrNew);
        end
    end



    function setXLim( )
        xLimHere = [min(xData), max(xData)];
        xLimOld = getappdata(handleAxes, 'IRIS_XLim');
        enforceXLimOld = getappdata(handleAxes, 'IRIS_EnforceXLim');
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
            xLimNew = xLimBefore;
        end
        xLimActual = getXLimActual(xLimNew);
        if ~isempty(xLimActual)
            set(handleAxes, 'XLim', xLimActual);
        end
        setappdata(handleAxes, 'IRIS_XLim', xLimNew);
        setappdata(handleAxes, 'IRIS_EnforceXLim', enforceXLimNew);
    end%


    function xData = setXTickLabelFormat( )
        if isempty(time) || timeFrequency==Frequency.INTEGER
            return
        end
        try
            handleAxes.XAxis.TickLabelFormat = opt.DateFormat;
        end
    end%


    function xLim = getXLimActual(xLim)
        xLimConstr = getappdata(handleAxes, 'IRIS_XLimConstraints');
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
        list = {
           'IRIS_PositionWithinPeriod'
           'IRIS_TimeSeriesPlot'
           'IRIS_XLim'
           'IRIS_EnforceXLim'
           'IRIS_XLimConstraints'
           'IRIS_XLim'
           'IRIS_XLim'
        };
        for i = 1 : numel(list)
            try
                rmappdata(handleAxes, list{i});
            end
        end
    end%
end%
