function [handlePlot, time, yData] = implementPlot(plotFun, varargin)
% implementPlot  Plot functions for TimeSubscriptable objects
%
% Backend function.
% No help provided.

% -Copyright (c) 2017 OGResearch Ltd.

IS_ROUND = @(x) isnumeric(x) && all(x==round(x));

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser(['TimeSubscriptable.implementPlot(', char(plotFun), ')']);
    INPUT_PARSER.KeepUnmatched = true;
    INPUT_PARSER.addRequired('PlotFun', @(x) isequal(x, @plot) || isequal(x, @bar) || isequal(x, @area) || isequal(x, @stem));
    INPUT_PARSER.addRequired('Axes', @(x) isequal(x, @gca) || (all(isgraphics(x, 'Axes')) && isscalar(x)));
    INPUT_PARSER.addRequired('Time', @(x) isa(x, 'Date') || isa(x, 'DateWrapper') || isequal(x, Inf) || isempty(x) || IS_ROUND(x));
    INPUT_PARSER.addRequired('Series', @(x) isa(x, 'TimeSubscriptable') && ~iscell(x.Data));
    INPUT_PARSER.addOptional('SpecString', cell.empty(1, 0), @(x) iscellstr(x)  && numel(x)<=1);
    INPUT_PARSER.addParameter('DateFormat', @default, @(x) isequal(x, @default) || ischar(x));
    INPUT_PARSER.addParameter('PositionWithinPeriod', @auto, @(x) isequal(x, @auto) ||  any(strcmpi(x, {'start', 'middle', 'end'})));
end

if isgraphics(varargin{1})
    axesHandle = varargin{1};
    varargin(1) = [ ];
else
    axesHandle = @gca;
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

INPUT_PARSER.parse(plotFun, axesHandle, time, this, varargin{:});
specString = INPUT_PARSER.Results.SpecString;
opt = INPUT_PARSER.Options;
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

if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle( );
end

[yData, time] = getData(this, time);
timeFrequency = getFrequency(time);

if ndims(yData)>2
    yData = yData(:, :);
end

positionWithinPeriod = resolvePositionWithinPeriod( );
xData = createDateAxis( );

handlePlot = plotFun(axesHandle, xData, yData, specString{:}, unmatchedOptions{:});
if enforceXLim
    set(axesHandle, 'XLim', xData([1, end]));
end

setappdata(axesHandle, 'IRIS_PositionWithinPeriod', positionWithinPeriod);
setappdata(axesHandle, 'IRIS_TimeSeriesPlot', true);

return


    function positionWithinPeriod = resolvePositionWithinPeriod( )
        axesPositionWithinPeriod = getappdata(axesHandle, 'IRIS_PositionWithinPeriod');
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
                    'TimeSubscriptable:implementPlot:DifferentPositionWithinPeriod', ...
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
