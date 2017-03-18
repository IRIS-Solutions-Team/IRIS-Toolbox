function mydatxtick(h, range, time, freq, userRange, opt)
% mydatxtick  Set up x-axis for Series object graphs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if numel(h)>1
    for i = 1 : numel(h)
        mydatxtick(h(i), time, freq, userRange, opt);
    end
    return
end

%--------------------------------------------------------------------------

if isequaln(time, NaN)
    return
end

% Does the axies object have a plotyy peer? Set the peer's xlim-related
% properties the same as in H; do not though set its xtick-related
% properties.
peer = getappdata(h, 'graphicsPlotyyPeer');
try
    % Catch delete peers.
    get(peer, 'XLim');
catch
    peer = [ ];
end

isZero = freq==0;
isWeekly = freq==52;
isDaily = freq==365;

% Determine x-limits first.
firstDate = [ ];
lastDate = [ ];
xLim = [ ];
setXLim( );

% Allow temporarily auto ticks and labels.
set(h, ...
    'xTickMode', 'auto', ...
    'xTickLabelMode', 'auto');

xTick = get(h(1), 'xTick');
xTickDates = [ ];

if isZero || isDaily
    setXTickZeroDaily( );
else
    setXTick( );
end

% Adjust x-limits if the graph includes bars.
adjustXLim( );




    function setXLim( )
        if isequal(userRange, Inf)
            if isZero
                firstDate = range(1);
                lastDate = range(end);
                xLim = [firstDate, lastDate];
            elseif isWeekly
                firstDate = range(1);
                lastDate = range(end);
                xLim = [time(1), time(end)];
            elseif isDaily
                % First day in first plotted month to last day in last plotted month.
                firstDate = double( datbom(range(1)) );
                lastDate = double( dateom(range(end)) );
                xLim = [firstDate, lastDate];
            else
                % First period in first plotted year to last period in last plotted year.
                firstDate = double( datcode(freq, floor(time(1)), 1) );
                lastDate = double( datcode(freq, floor(time(end)), freq) );
                xLim = dat2dec([firstDate, lastDate], opt.DatePosition);
            end
        else
            firstDate = userRange(1);
            lastDate = userRange(end);
            xLim = dat2dec([firstDate, lastDate], opt.DatePosition);
        end
        xLim = double(xLim);
        while xLim(2)<=xLim(1)
            xLim(2) = xLim(2) + 0.5;
        end
        set([h, peer], ...
            'xLim', xLim, ...
            'xLimMode', 'manual');
    end 



    
    function setXTick( )
        if isequal(opt.DateTick, Inf)
            utils.error('dates:mydatxtick', ...
                ['Inf is an obsolete value for the option ''dateTick=''. ', ...
                'Use @auto instead.']);
        elseif isequal(opt.DateTick, @auto)
            % Determine step and xTick.
            % Step is number of periods.
            % If multiple axes handles are passed in (e.g. plotyy) use just
            % the first one to get xTick but set the properties for both
            % eventually.
            if length(xTick) > 1
                step = max(1, round(freq*(xTick(2) - xTick(1))));
            else
                step = 1;
            end
            xTickDates = firstDate : step : lastDate;
        elseif isnumeric(opt.DateTick)
            xTickDates = opt.DateTick;
        elseif ischar(opt.DateTick)
            tempRange = firstDate : lastDate;
            [~, tempPer] = dat2ypf(tempRange);
            switch lower(opt.DateTick)
                case 'yearstart'
                    xTickDates = tempRange(tempPer==1);
                case 'yearend'
                    xTickDates = tempRange(tempPer==freq);
                case 'yearly'
                    match = tempPer(1);
                    if freq==52 && match==53
                        match = 52;
                        xTickDates = tempRange(tempPer==match);
                        xTickDates = [tempRange(1), xTickDates];
                    else
                        xTickDates = tempRange(tempPer==match);
                    end
            end
        end
        xTick = dat2dec(xTickDates, opt.DatePosition);
        setXTickLabel( );
    end 




    function setXTickZeroDaily( )
        % Make sure the xTick step is not smaller than 1.
        if isequal(opt.DateTick, Inf)
            utils.error('dates:mydatxtick', ...
                ['Inf is an obsolete value for the option ''dateTick=''. ', ...
                'Use @auto instead.']);
        elseif isequal(opt.DateTick, @auto)
            % Do nothing.
        else
            xTick = opt.DateTick;
        end
        if any(diff(xTick)<1)
            xTick = xTick(1) : xTick(end);
        end
        xTickDates = xTick;
        setXTickLabel( );
    end 



    
    function setXTickLabel( )
        set(h, ...
            'xTick', xTick, ...
            'xTickMode', 'manual');
        % Set xTickLabel.
        opt = datdefaults(opt, true);
        % Default value for '.plotDateFormat' is a struct with a different
        % date format for each date frequency. Fetch the right date format
        % now, and pass it into `dat2str( )`.
        if isstruct(opt.dateformat)
            opt.dateformat = dates.Date.chooseFormat(opt.dateformat, freq);
        end
        if freq==0 && strcmp(opt.dateformat, 'P')
            return
        end
        xTickLabel = dat2str(xTickDates, opt);
        set(h, ...
            'xTickLabel', xTickLabel, ...
            'xTickLabelMode', 'manual');
    end 



    
    function adjustXLim( )
        % Expand x-limits for bar graphs, or make sure they are kept wide if a bar
        % graph is added a non-bar plot.
        if isequal(getappdata(h, 'IRIS_XLIM_ADJUST'), true)
            if freq==0 || freq==365
                xLimAdjust = 0.5;
            else
                xLimAdjust = 0.5/freq;
            end
            xLim = get(h, 'XLim');
            set([h, peer], 'XLim', xLim + [-xLimAdjust, xLimAdjust]);
            setappdata(h, 'IRIS_TRUE_XLIM', xLim);
            if ~isempty(peer)
                setappdata(peer, 'IRIS_TRUE_XLIM', xLim);
            end
        end
    end 
end
