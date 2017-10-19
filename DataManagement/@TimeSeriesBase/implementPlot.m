function hPlot = implementPlot(plotFun, varargin)
% implementPlot  Plot functions for TimeSeriesBase objects.
%
% Backend function.
% No help provided.

% -Copyright (c) 2017 OGResearch Ltd.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser(['TimeSeriesBase/implementPlot', char(plotFun)]);
    INPUT_PARSER.KeepUnmatched = true;
    INPUT_PARSER.addRequired('PlotFun', @(x) isequal(x, @plot));
    INPUT_PARSER.addRequired('Axes', @(x) isempty(x) || (isgraphics(x) && length(x)==1));
    INPUT_PARSER.addRequired('Time', @(x) isa(x, 'Date') || isa(x, 'DateWrapper') || isequal(x, Inf) || isempty(x));
    INPUT_PARSER.addRequired('Series', @(x) isa(x, 'TimeSeriesBase') && ~iscell(x.Data));
    INPUT_PARSER.addParameter('DateFormat', @default, @(x) isequal(x, @default) || ischar(x));
    INPUT_PARSER.addParameter('DatePosition', 'middle', @(x) any(strcmpi(x, {'start', 'middle', 'end'})));
end

if isgraphics(varargin{1})
    hAxes = varargin{1};
    varargin(1) = [ ];
else
    hAxes = gca( );
end

if isa(varargin{1}, 'Date')  || isa(varargin{1}, 'DateWrapper') || isequal(varargin{1}, Inf)
    time = varargin{1};
    varargin(1) = [ ];
else
    time = Inf;
end

this = varargin{1};
varargin(1) = [ ];

INPUT_PARSER.parse(plotFun, hAxes, time, this, varargin{:});
opt = INPUT_PARSER.Results;
unmatchedOptions = INPUT_PARSER.Unmatched;

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

yData = getData(this, time);
timeFrequency = getFrequency(time);

if timeFrequency==Frequency.INTEGER
    xData = getSerial(time);
else
    xData = datetime(time, lower(opt.DatePosition));
    if ~isequal(opt.DateFormat, @default)
        xData.Format = opt.DateFormat;
    end
end

hPlot = plotFun(hAxes, xData, yData, unmatchedOptions);
if enforceXLim
    set(hAxes, 'XLim', xData([1, end]));
end

end
