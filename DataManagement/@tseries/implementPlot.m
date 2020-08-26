function [ axesHandle, plotHandle, ...
           inputRange, data, ...
           xCoor, userRange, freq ] = implementPlot(plotFunc, varargin)
% implementPlot  Implement plot function for tseries objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

% If the caller supplies empty `Func`, the graph will not be actually
% rendered. This is a dry call to `implementPlot` used from within `plotyy`.

persistent parser
if isempty(parser)
    parser = extend.InputParser('tseries.implementPlot');
    parser.KeepUnmatched = true;
    parser.addParameter('Comprise', [ ], @(x) isempty(x) || DateWrapper.validateDateInput(x));
    parser.addPlotOptions( );
    parser.addDateOptions('tseries');
end

if isempty(plotFunc)
    [axesHandle, inputRange, this, plotSpec, opt] = varargin{:};
else
    [axesHandle, inputRange, this, plotSpec, varargin] = ...
        NumericTimeSubscriptable.preparePlot(varargin{:});
    parser.parse(varargin{:});
    opt = parser.Options;
    varargin = parser.UnmatchedInCell;
end
userRange = inputRange;
 
%--------------------------------------------------------------------------

% Resize input time series to input range if needed
if ~isequal(inputRange, Inf) && ~isequal(inputRange, @all) && ~isnan(this.Start)
    inputRange = inputRange(:).';    
    if ~all( freqcmp(this, inputRange) )
        THIS_ERROR = { 'tseries:DateFrequencyMismatch'
                       'Date frequency mismatch between input range and input time series' };
        throw( exception.Base(THIS_ERROR, 'error') );
    end
    this = resize(this, inputRange);
end

if isempty(plotSpec)
    plotSpec = cell.empty(1, 0);
elseif ischar(plotSpec)
    plotSpec = { plotSpec };
end

this.data = this.data(:, :);
inputRange = specrange(this, inputRange);

plotHandle = [ ];
if isempty(inputRange)
    data = this.data([ ], :);
    xCoor = double.empty(1, 0);
    THIS_WARNING = { 'tseries:NoDataPlotted'
                     'No data plotted because input range is empty' };
    throw( exception.Base(THIS_WARNING, 'warning') );
    return
end

freq = dater.getFrequency( inputRange(1) );

if ~isempty(plotFunc) && isa(axesHandle, 'function_handle')
    axesHandle = axesHandle( );
end

% If hold==on, make sure the new range comprises thes existing dates if
% the existing graph is a tseries graph
if ~isempty(plotFunc) ...
        && ~isempty(inputRange) && strcmp(get(axesHandle, 'nextPlot'), 'add') ...
        && isequal(getappdata(axesHandle, 'IRIS_SERIES'), true)
    oldFreq = getappdata(axesHandle, 'IRIS_FREQ');
    if (oldFreq==365 && freq~=365) ...
       || (oldFreq~=365 && freq==365)
        utils.error('tseries:implementPlot', ...
            'Cannot combined daily and non-daily tseries in one graph.');
    end
    % Original x-axis limits.
    if isequal(getappdata(axesHandle, 'IRIS_XLIM_ADJUST'), true)
        xLim0 = getappdata(axesHandle, 'IRIS_TRUE_XLIM');
    else
        xLim0 = get(axesHandle, 'xLim');
    end
    inputRange = mergeRange(inputRange([1, end]), xLim0);
end

% Make sure the new range and `UsrRng` both comprise the `Comprise`
% dates; this is used in `plotyy`.
if ~isempty(opt.Comprise)
    inputRange = mergeRange(inputRange, opt.Comprise);
    if ~isequal(userRange, Inf)
        userRange = mergeRange(userRange, opt.Comprise);
    end
end

checkFrequency(this, inputRange);
data = getData(this, inputRange);
xCoor = dat2dec(inputRange, opt.DatePosition);

if isempty(plotFunc)
    return
end

% Do the actual plot.
set(axesHandle, 'xTickMode', 'auto', 'xTickLabelMode', 'auto');
[plotHandle, isTimeAxis] = this.plotSwitchboard( plotFunc, ...
                                                 axesHandle, ...
                                                 xCoor, ...
                                                 data, ...
                                                 plotSpec, ...
                                                 false, ...
                                                 varargin{:} );

isBar = isequal(plotFunc, @bar) ...
     || isequal(plotFunc, @barcon) ...
     || isequal(plotFunc, @numeric.barcon);

if isequal(opt.XLimMargins, true) || (isequal(opt.XLimMargins, @auto) && isBar)
    setappdata(axesHandle, 'IRIS_XLIM_ADJUST', true);
    peer = getappdata(axesHandle, 'graphicsPlotyyPeer');
    if ~isempty(peer)
        setappdata(peer, 'IRIS_XLIM_ADJUST', true);
    end
end

% `Time` can be `NaN` when the input tseries is empty.
try
    isTimeNan = isequaln(xCoor, NaN);
catch %#ok<CTCH>
    % Old syntax.
    isTimeNan = isequalwithequalnans(xCoor, NaN); %#ok<FPARK>
end

% Set up the x-axis with proper dates. Do not do this if `time` is NaN, 
% which happens with empty tseries.
if isTimeAxis && ~isTimeNan
    setappdata(axesHandle, 'IRIS_SERIES', true);
    setappdata(axesHandle, 'IRIS_FREQ', freq);
    setappdata(axesHandle, 'IRIS_RANGE', inputRange);
    setappdata(axesHandle, 'IRIS_DATE_POSITION', opt.DatePosition);
    mydatxtick(axesHandle, inputRange, xCoor, freq, userRange, opt);
end

% Perform user supplied function.
if ~isempty(opt.Function)
    opt.Function(plotHandle);
end

% Make the y-axis tight.
if opt.Tight
    grfun.yaxistight(axesHandle);
end

% Datatip cursor
%----------------
% Store the dates within each plotted object for later retrieval by
% datatip cursor.
for ih = plotHandle(:).'
    setappdata(ih, 'IRIS_DATELINE', inputRange);
end

if true % ##### MOSW
    % Use IRIS datatip cursor function in this figure; in
    % `utils.datacursor` we also handle cases where the current figure
    % includes both tseries and non-tseries graphs.
    obj = datacursormode(gcf( ));
    set(obj, 'UpdateFcn', @utils.datacursor);
else
    % Do nothing.
end

return


    function range = mergeRange(range, comprise)
        % first = dec2dat(Comprise(1), Freq, Opt.DatePosition);
        first = double(range(1));
        % Make sure ranges with different frequencies are merged
        % properly.
        while dat2dec(first-1, opt.DatePosition)>=comprise(1)
            first = first - 1;
        end
        % last = dec2dat(Comprise(end), Freq, Opt.DatePosition);
        last = double(range(end));
        while dat2dec(last+1, opt.DatePosition)<=comprise(end)
            last = last + 1;
        end
        range = double(first) : double(last);
    end%
end%
