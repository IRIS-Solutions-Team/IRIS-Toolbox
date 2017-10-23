function [hPlot, time, yData] = implementPlot(plotFun, varargin)
% implementPlot  Plot functions for TimeSeriesBase objects.
%
% Backend function.
% No help provided.

% -Copyright (c) 2017 OGResearch Ltd.

IS_ROUND = @(x) isnumeric(x) && all(x==round(x));

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser(['TimeSeriesBase.implementPlot(', char(plotFun), ')']);
    INPUT_PARSER.KeepUnmatched = true;
    INPUT_PARSER.addRequired('PlotFun', @(x) isequal(x, @plot) || isequal(x, @bar) || isequal(x, @area) || isequal(x, @stem));
    INPUT_PARSER.addRequired('Axes', @(x) isempty(x) || (isgraphics(x) && length(x)==1));
    INPUT_PARSER.addRequired('Time', @(x) isa(x, 'Date') || isa(x, 'DateWrapper') || isequal(x, Inf) || isempty(x) || IS_ROUND(x));
    INPUT_PARSER.addRequired('Series', @(x) isa(x, 'TimeSeriesBase') && ~iscell(x.Data));
    INPUT_PARSER.addParameter('DateFormat', @default, @(x) isequal(x, @default) || ischar(x));
    INPUT_PARSER.addParameter('PositionWithinPeriod', @auto, @(x) isequal(x, @auto) ||  any(strcmpi(x, {'start', 'middle', 'end'})));
end

if isgraphics(varargin{1})
    handleAxes = varargin{1};
    varargin(1) = [ ];
else
    handleAxes = gca( );
end

if isa(varargin{1}, 'Date')  || isa(varargin{1}, 'DateWrapper') || isequal(varargin{1}, Inf)
    time = varargin{1};
    varargin(1) = [ ];
elseif ~isequal(varargin{1}, Inf) && IS_ROUND(varargin{1})
    time = DateWrapper.fromDouble(varargin{1});
    varargin(1) = [ ];
else
    time = Inf;
end

this = varargin{1};
varargin(1) = [ ];

INPUT_PARSER.parse(plotFun, handleAxes, time, this, varargin{:});
opt = INPUT_PARSER.Results;
unmatchedOptions = INPUT_PARSER.UnmatchedInCell;

enforceXLim = true;
if isequal(time, Inf)
    time = this.Range;
    enforceXLim = false;
elseif isempty(time) || isnad(time)
    time = this.Start;
    time = time([ ], 1);
else
    time = time(:);
end

assert( ...
    isnan(this.Start) || validateDate(this, time), ...
    'TimeSeries:implementPlot:IllegalDate', ...
    'Illegal date or date frequency.' ...
);

%--------------------------------------------------------------------------

[yData, time] = getData(this, time);
timeFrequency = getFrequency(time);

positionWithinPeriod = resolvePositionWithinPeriod( );
xData = createDateAxis( );

hPlot = plotFun(handleAxes, xData, yData, unmatchedOptions{:});
if enforceXLim
    set(handleAxes, 'XLim', xData([1, end]));
end

setappdata(handleAxes, 'IRIS_PositionWithinPeriod', positionWithinPeriod);

return


    function positionWithinPeriod = resolvePositionWithinPeriod( )
        axesPositionWithinPeriod = getappdata(handleAxes, 'IRIS_PositionWithinPeriod');
        positionWithinPeriod = opt.PositionWithinPeriod;
        if isempty(axesPositionWithinPeriod) 
            if isequal(positionWithinPeriod, @auto)
                positionWithinPeriod = 'start';
            end
        else
            if isequal(positionWithinPeriod, @auto)
                positionWithinPeriod = axesPositionWithinPeriod;
            elseif ~isequal(axesPositionWithinPeriod, positionWithinPeriod)
                warning( ...
                    'TimeSeriesBase:implementPlot:DifferentPositionWithinPeriod', ...
                    'Option PositionWithinPeriod= differs from the value set in the current Axes.' ...
                );
            end
        end
    end


    function xData = createDateAxis( )
        if timeFrequency==Frequency.INTEGER
            xData = getSerial(time);
        else
            xData = datetime(time, lower(positionWithinPeriod));
            if ~isequal(opt.DateFormat, @default)
                xData.Format = opt.DateFormat;
            end
        end
    end
end
