function [Ax,hLhs,hRhs,RangeLhs,dataLhs,timeLhs,RangeRhs,dataRhs,timeRhs] ...
    = plotyy(varargin)
% plotyy  Line plot function with LHS and RHS axes for time series.
%
% Syntax
% =======
%
%     [Ax,Lhs,Rhs,Range] = plotyy(X,Y,...)
%     [Ax,Lhs,Rhs,Range] = plotyy(Range,X,Y,...)
%     [Ax,Lhs,Rhs,Range] = plotyy(RangeLhs,X,RangeRhs,Y,...)
%
% Input arguments
% ================
%
% * `Range` [ numeric | char ] - Date range; if not specified the entire
% range of the input tseries object will be plotted.
%
% * `RangeLhs` [ numeric | char ] - LHS plot date range.
%
% * `RangeRhs` [ numeric | char ] - RHS plot date range.
%
% * `X` [ tseries ] - Input tseries object whose columns will be plotted
% and labelled on the LHS.
%
% * `Y` [ tseries ] - Input tseries object whose columns will be plotted
% and labelled on the RHS.
%
% Output arguments
% =================
%
% * `Ax` [ handle | numeric ] - Handles to the LHS and RHS axes.
%
% * `Lhs` [ handle | numeric ] - Handles to series plotted on the LHS axis.
%
% * `Rhs` [ handle | numeric ] - Handles to series plotted on the RHS axis.
%
% * `Range` [ handle | numeric ] - Actually plotted date range.
%
% Options
% ========
%
% * `'coincide='` [ `true` | *`false`* ] - Make the LHS and RHS y-axis
% grids coincide.
%
% * `'lhsPlotFunc='` [ `@area` | `@bar` | *`@plot`* | `@stem` ] - Function
% that will be used to plot the LHS data.
%
% * `'lhsTight='` [ `true` | *`false`* ] - Make the LHS y-axis tight.
%
% * `'rhsPlotFunc='` [ `@area` | `@bar` | *`@plot`* | `@stem` ] - Function
% that will be used to plot the RHS data.
%
% * `'rhsTight='` [ `true` | *`false`* ] - Make the RHS y-axis tight.
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `plotyy` for all options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

% Range for LHS time series.
if isdatinp(varargin{1})
    RangeLhs = varargin{1};
    varargin(1) = [ ];
else
    RangeLhs = Inf;
end

% LHS time series.
XLhs = varargin{1};
varargin(1) = [ ];

% Range for RHS time series.
if isdatinp(varargin{1})
    RangeRhs = varargin{1};
    varargin(1) = [ ];
else
    RangeRhs = RangeLhs;
end

% RHS time series.
XRhs = varargin{1};
varargin(1) = [ ];

[opt,varargin] = passvalopt('tseries.plotyy',varargin{:});

if ischar(RangeLhs)
    RangeLhs = textinp2dat(RangeLhs);
end
if ischar(RangeRhs)
    RangeRhs = textinp2dat(RangeRhs);
end

%--------------------------------------------------------------------------

% Check consistency of ranges and time series.
% LHS.
if ~all(isinf(RangeLhs)) && ~isempty(RangeLhs) && ~isempty(XLhs) ...
        && isa(XLhs,'tseries')
    if datfreq(RangeLhs(1)) ~= get(XLhs,'freq')
        utils.error('tseries:plotyy', ...
            ['LHS range and LHS time series must have ', ...
            'the same date frequency.']);
    end
end
% RHS.
if ~all(isinf(RangeRhs)) && ~isempty(RangeRhs) && ~isempty(XRhs) ...
        && isa(XRhs,'tseries')
    if datfreq(RangeRhs(1)) ~= get(XRhs,'freq')
        utils.error('tseries:plotyy', ...
            ['RHS range and RHS time series must have ', ...
            'the same date frequency.']);
    end
end

% Mimic plotting the RHS graph without creating an axes object.
[~,~,RangeRhs,dataRhs,timeRhs,userRangeRhs,freqRhs] = ...
    tseries.myplot([ ],[ ],RangeRhs,[ ],XRhs,'',opt); %#ok<ASGLU>

% Mimic plotting the LHS graph without creating an axes object.
comprise = timeRhs([1,end]);
[~,~,RangeLhs,dataLhs,timeLhs,userRangeLhs,freqLhs] = ...
    tseries.myplot([ ],[ ],RangeLhs,comprise,XLhs,'',opt);

% Plot now.
dataLhsPlot = grfun.myreplacenancols(dataLhs,Inf);
dataRhsPlot = grfun.myreplacenancols(dataRhs,Inf);
lhsPlotFuncStr = opt.lhsplotfunc;
rhsPlotFuncStr = opt.rhsplotfunc;
if isfunc(lhsPlotFuncStr)
    lhsPlotFuncStr = func2str(lhsPlotFuncStr);
end
if isfunc(rhsPlotFuncStr)
    rhsPlotFuncStr = func2str(rhsPlotFuncStr);
end
[Ax,hLhs,hRhs] = plotyy(timeLhs,dataLhsPlot,timeRhs,dataRhsPlot, ...
    lhsPlotFuncStr,rhsPlotFuncStr);

% Apply line properties passed in by the user as optional arguments. Do
% it separately for `hl` and `hr` because they each can be different types.
if ~isempty(varargin)
    try %#ok<*TRYNC>
        set(hLhs,varargin{:});
    end
    try
        set(hRhs, varargin{:});
    end
end

setappdata(Ax(1),'IRIS_SERIES', true);
setappdata(Ax(1),'IRIS_FREQ', freqLhs);
setappdata(Ax(1),'IRIS_RANGE', RangeLhs);
setappdata(Ax(1),'IRIS_DATE_POSITION', opt.DatePosition);

setappdata(Ax(2),'IRIS_SERIES', true);
setappdata(Ax(2),'IRIS_FREQ', freqRhs);
setappdata(Ax(2),'IRIS_RANGE', RangeRhs);
setappdata(Ax(2),'IRIS_DATE_POSITION', opt.DatePosition);

if strcmp(lhsPlotFuncStr, 'bar') || strcmp(rhsPlotFuncStr, 'bar')
    setappdata(Ax(1), 'IRIS_XLIM_ADJUST',true);
    setappdata(Ax(2), 'IRIS_XLIM_ADJUST',true);
end

% Prevent LHS y-axis tick marks on the RHS, and vice versa by turning the
% box off for both axis. To draw a complete box, add a top edge line by
% displaying the x-axis at the top in the first axes object (the x-axis is
% empty, has no ticks or labels).
set(Ax, 'Box', 'Off');
set( Ax(2), 'Color', 'None', ...
    'XTickLabel','', ...
    'XTick', [ ], ...
    'XAxisLocation', 'top' );
try
    Ax(2).XRuler.Visible = 'on';
end

mydatxtick(Ax(1), RangeLhs, timeLhs, freqLhs, userRangeLhs, opt);

% For bkw compatibility only, not documented. Use of `highlight` outside
% `plotyy` is now safe.
if ~isempty(opt.highlight)
    highlight(Ax(1), opt.highlight);
end

if opt.lhstight || opt.tight
    grfun.yaxistight(Ax(1));
end

if opt.rhstight || opt.tight
    grfun.yaxistight(Ax(2));
end

% Make sure the RHS axes object is on the background. We need this for e.g.
% `plotcmp` graphs.
grfun.swaplhsrhs(Ax(1), Ax(2));

if ~opt.coincide
    set(Ax, 'YTickMode', 'Auto');
end

% Datatip cursor
%----------------
% Store the dates within each plotted object for later retrieval by
% datatip cursor.
for ih = hLhs(:).'
    setappdata(ih, 'IRIS_DATELINE', RangeLhs);
end 
for ih = hRhs(:).'
    setappdata(ih, 'IRIS_DATELINE', RangeRhs);
end

if true % ##### MOSW
    % Use IRIS datatip cursor function in this figure; in
    % `utils.datacursor', we also handle cases where the current figure
    % includes both tseries and non-tseries graphs.
    obj = datacursormode(gcf( ));
    set(obj, 'UpdateFcn', @utils.datacursor);
else
    % Do nothing.
end
end
