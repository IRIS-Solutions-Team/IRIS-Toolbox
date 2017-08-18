function hPlot = implementPlot(plotFun, varargin)
% implementPlot  Plot functions for TimeSeries objects.
%
% Backend function.
% No help provided.

% -Copyright (c) 2017 OGResearch Ltd.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser(['TimeSeries/implementPlot', char(plotFun)]);
    INPUT_PARSER.KeepUnmatched = true;
    INPUT_PARSER.addRequired('PlotFun', @(x) isequal(x, @plot));
    INPUT_PARSER.addRequired('Axes', @(x) isempty(x) || (isgraphics(x) && length(x)==1));
    INPUT_PARSER.addRequired('Time', @(x) isa(x, 'Date') || isequal(x, Inf) || isempty(x));
    INPUT_PARSER.addRequired('Series', @(x) isa(x, 'TimeSeries') && ~iscell(x.Data));
    INPUT_PARSER.addParameter('DateFormat', @default, @(x) isequal(x, @default) || ischar(x));
    INPUT_PARSER.addParameter('DatePosition', 'middle', @(x) any(strcmpi(x, {'start', 'middle', 'end'})));
end

if isgraphics(varargin{1})
    hAxes = varargin{1};
    varargin(1) = [ ];
else
    hAxes = gca( );
end

if isa(varargin{1}, 'Date') || isequal(varargin{1}, Inf)
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
    validate(this.Start, time), ...
    'TimeSeries:implementPlot', ...
    'Inconsistent date frequency.' ...
);

%--------------------------------------------------------------------------

yData = getData(this, time);

if time.Frequency==Frequency.INTEGER
    xData = time.Serial;
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
