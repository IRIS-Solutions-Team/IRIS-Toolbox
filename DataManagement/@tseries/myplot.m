function [hAx, hPlot, rng, data, xCoor, usrRng, freq] ...
    = myplot(func, hAx, rng, comprise, this, plotSpec, opt, varargin)
% myplot  Master plot function for tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% If the caller supplies empty `Func`, the graph will not be actually
% rendered. This is a dry call to `myplot` used from within `plotyy`.

usrRng = rng;

% Resize input time series to input range if needed.
if ~isequal(rng, Inf) && ~isequal(rng, @all) && ~isnan(this.Start)
    rng = rng(:).';    
    if ~all( freqcmp(this, rng) )
        utils.error('tseries:myplot', ...
            ['Date frequency mismatch between ', ...
            'input range and input time series.']);
    end
    this = resize(this, rng);
end

if isempty(plotSpec)
    plotSpec = { };
elseif ischar(plotSpec)
    plotSpec = { plotSpec };
end

%--------------------------------------------------------------------------

this.data = this.data(:, :);
[~, nx] = size(this.data);
rng = specrange(this, rng);

hPlot = [ ];
if isempty(rng)
    utils.warning('tseries:myplot', ...
        'No graph displayed because date range is empty.');
    return
end

freq = DateWrapper.getFrequencyFromNumeric( rng(1) );

if ~isempty(func) && isa(hAx, 'function_handle')
    hAx = hAx( );
end

% If hold==on, make sure the new range comprises thes existing dates if
% the existing graph is a tseries graph.
if ~isempty(func) ...
        && ~isempty(rng) && strcmp(get(hAx, 'nextPlot'), 'add') ...
        && isequal(getappdata(hAx, 'IRIS_SERIES'), true)
    oldFreq = getappdata(hAx, 'IRIS_FREQ');
    if (oldFreq==365 && freq ~= 365) ...
            || (oldFreq ~= 365 && freq==365)
        utils.error('tseries:myplot', ...
            'Cannot combined daily and non-daily tseries in one graph.');
    end
    % Original x-axis limits.
    if isequal(getappdata(hAx, 'IRIS_XLIM_ADJUST'), true)
        xLim0 = getappdata(hAx, 'IRIS_TRUE_XLIM');
    else
        xLim0 = get(hAx, 'xLim');
    end
    rng = mergeRange(rng([1, end]), xLim0);
end

% Make sure the new range and `UsrRng` both comprise the `Comprise`
% dates; this is used in `plotyy`.
if ~isempty(comprise)
    rng = mergeRange(rng, comprise);
    if ~isequal(usrRng, Inf)
        usrRng = mergeRange(usrRng, comprise);
    end
end

data = mygetdata(this, rng);
xCoor = dat2dec(rng, opt.DatePosition);

if isempty(func)
    return
end

% Do the actual plot.
set(hAx, 'xTickMode', 'auto', 'xTickLabelMode', 'auto');
[hPlot, isTimeAxis] = callPlotFunc( );

if isequal(opt.xlimmargin, true) ...
        || ( isequal(opt.xlimmargin, @auto) ...
        && ( isequal(func, @bar) || isequal(func, @barcon) ))
    setappdata(hAx, 'IRIS_XLIM_ADJUST', true);
    peer = getappdata(hAx, 'graphicsPlotyyPeer');
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
    setappdata(hAx, 'IRIS_SERIES', true);
    setappdata(hAx, 'IRIS_FREQ', freq);
    setappdata(hAx, 'IRIS_RANGE', rng);
    setappdata(hAx, 'IRIS_DATE_POSITION', opt.DatePosition);
    mydatxtick(hAx, rng, xCoor, freq, usrRng, opt);
end

% Perform user supplied function.
if ~isempty(opt.function)
    opt.function(hPlot);
end

% Make the y-axis tight.
if opt.tight
    grfun.yaxistight(hAx);
end

% Datatip cursor
%----------------
% Store the dates within each plotted object for later retrieval by
% datatip cursor.
for ih = hPlot(:).'
    setappdata(ih, 'IRIS_DATELINE', rng);
end

if true % ##### MOSW
    % Use IRIS datatip cursor function in this figure; in `utils.datacursor', 
    % we also handle cases where the current figure includes both tseries and
    % non-tseries graphs.
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
    end




    function [h, isTimeAxis] = callPlotFunc( )
        FuncStr = func;
        if isfunc(FuncStr)
            FuncStr = func2str(FuncStr);
        end
        switch FuncStr
            case {'scatter'}
                if nx==2
                    h = scatter(hAx, data(:, 1), data(:, 2), plotSpec{:});
                elseif nx==3
                    h = scatter(hAx, data(:, 1), data(:, 2), data(:, 3), plotSpec{:});
                elseif nx==4
                    h = scatter(hAx, data(:, 1), data(:, 2), data(:, 3), data(:, 4), plotSpec{:});
                else
                    utils.error('tseries:myplot', ...
                        ['Scatter plot input data must have ', ...
                        'exactly two or three columns.']);
                end
                if ~isempty(varargin)
                    set(h, varargin{:});
                end
                isTimeAxis = false;
            case {'histogram'}
                h = histogram(hAx, data, plotSpec{:});
                isTimeAxis = false;
            case {'barcon'}
                % Do not pass `plotspecs` but do pass user options.
                h = tseries.mybarcon(hAx, xCoor, data, varargin{:});
                isTimeAxis = true;
            otherwise
                DataInf = grfun.myreplacenancols(data, Inf);
                h = feval(func, hAx, xCoor, DataInf, plotSpec{:});
                if ~isempty(varargin)
                    set(h, varargin{:});
                end
                isTimeAxis = true;
        end
    end 
end
