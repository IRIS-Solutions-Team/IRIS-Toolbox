function [ ax, hLhs, hRhs, rangeLhs, dataLhs, ...
           timeLhs, rangeRhs, dataRhs, timeRhs ] = plotyy(varargin)
% plotyy  Line plot function with LHS and RHS axes for time series
%
% __Syntax__
%
%     [Ax, Lhs, Rhs, Range] = plotyy(X, Y, ...)
%     [Ax, Lhs, Rhs, Range] = plotyy(Range, X, Y, ...)
%     [Ax, Lhs, Rhs, Range] = plotyy(LhsRange, X, RhsRange, Y, ...)
%
%
% __Input arguments__
%
% * `Range` [ numeric | char ] - Date range; if not specified the entire
% range of the input tseries object will be plotted.
%
% * `LhsRange` [ numeric | char ] - LHS plot date range.
%
% * `RhsRange` [ numeric | char ] - RHS plot date range.
%
% * `X` [ Series ] - Input tseries object whose columns will be plotted
% and labelled on the LHS.
%
% * `Y` [ Series ] - Input tseries object whose columns will be plotted
% and labelled on the RHS.
%
%
% __Output arguments__
%
% * `Ax` [ Axes ] - Handles to the LHS and RHS axes.
%
% * `Lhs` [ Axes ] - Handles to series plotted on the LHS axis.
%
% * `Rhs` [ Line ] - Handles to series plotted on the RHS axis.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
%
% __Options__
%
% * `'Coincide='` [ `true` | *`false`* ] - Make the LHS and RHS y-axis
% grids coincide.
%
% * `'LhsPlotFunc='` [ `@area` | `@bar` | *`@plot`* | `@stem` ] - Function
% that will be used to plot the LHS data.
%
% * `'LhsTight='` [ `true` | *`false`* ] - Make the LHS y-axis tight.
%
% * `'RhsPlotFunc='` [ `@area` | `@bar` | *`@plot`* | `@stem` ] - Function
% that will be used to plot the RHS data.
%
% * `'RhsTight='` [ `true` | *`false`* ] - Make the RHS y-axis tight.
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `plotyy` for all options available.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

% Range for LHS time series
if Dater.validateDateInput(varargin{1})
    rangeLhs = varargin{1};
    varargin(1) = [ ];
else
    rangeLhs = Inf;
end

% LHS time series.
XLhs = varargin{1};
varargin(1) = [ ];

% range for RHS time series.
if Dater.validateDateInput(varargin{1})
    rangeRhs = varargin{1};
    varargin(1) = [ ];
else
    rangeRhs = rangeLhs;
end

% RHS time series.
XRhs = varargin{1};
varargin(1) = [ ];

persistent parser
if isempty(parser)
    parser = extend.InputParser('tseries.plotyy');
    parser.addRequired('LhsRange', @Dater.validateDateInput);
    parser.addRequired('RhsRange', @Dater.validateDateInput);
    parser.addRequired('LhsSeries', @(x) isa(x, 'tseries'));
    parser.addRequired('RhsSeries', @(x) isa(x, 'tseries'));
    parser.addParameter({'Coincide', 'Coincident'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Highlight', [ ], @isnumeric);
    parser.addParameter('LhsPlotFunc', @plot, @(x) ischar(x) || isa(x, 'function_handle'));
    parser.addParameter('RhsPlotFunc', @plot, @(x) ischar(x) || isa(x, 'function_handle'));
    parser.addParameter('LhsTight', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('RhsTight', false, @(x) isequal(x, true) || isequal(x, false) );
    parser.addDateOptions('tseries');
    parser.addPlotOptions( );
end
parser.parse(rangeLhs, rangeRhs, XLhs, XRhs, varargin{:});
opt = parser.Options;

if ischar(rangeLhs)
    rangeLhs = textinp2dat(rangeLhs);
end
if ischar(rangeRhs)
    rangeRhs = textinp2dat(rangeRhs);
end

%--------------------------------------------------------------------------

% Check consistency of ranges and time series.
% LHS.
if ~all(isinf(rangeLhs)) && ~isempty(rangeLhs) && ~isempty(XLhs) ...
        && isa(XLhs, 'TimeSubscriptable')
    if dater.getFrequency(rangeLhs(1))~=XLhs.FrequencyAsNumeric
        utils.error('tseries:plotyy', ...
            ['LHS range and LHS time series must have ', ...
            'the same date frequency.']);
    end
end
% RHS.
if ~all(isinf(rangeRhs)) && ~isempty(rangeRhs) && ~isempty(XRhs) ...
        && isa(XRhs, 'tseries')
    if dater.getFrequency(rangeRhs(1))~=XRhs.FrequencyAsNumeric
        utils.error('tseries:plotyy', ...
            ['RHS range and RHS time series must have ', ...
            'the same date frequency.']);
    end
end

% Mimic plotting the RHS graph without creating an axes object
opt.Comprise = [ ];
[~, ~, rangeRhs, dataRhs, timeRhs, userRangeRhs, freqRhs] = ...
    tseries.implementPlot([ ], gobjects(0), rangeRhs, XRhs, '', opt); %#ok<ASGLU>

% Mimic plotting the LHS graph without creating an axes object
opt.Comprise = timeRhs([1, end]);
[~, ~, rangeLhs, dataLhs, timeLhs, userRangeLhs, freqLhs] = ...
    tseries.implementPlot([ ], gobjects(0), rangeLhs, XLhs, '', opt);

% Plot now.
dataLhsPlot = grfun.myreplacenancols(dataLhs, Inf);
dataRhsPlot = grfun.myreplacenancols(dataRhs, Inf);
lhsPlotFuncStr = opt.LhsPlotFunc;
rhsPlotFuncStr = opt.RhsPlotFunc;
if isfunc(lhsPlotFuncStr)
    lhsPlotFuncStr = func2str(lhsPlotFuncStr);
end
if isfunc(rhsPlotFuncStr)
    rhsPlotFuncStr = func2str(rhsPlotFuncStr);
end
[ax, hLhs, hRhs] = plotyy( timeLhs, dataLhsPlot, timeRhs, dataRhsPlot, ...
                           lhsPlotFuncStr, rhsPlotFuncStr );

% Apply line properties passed in by the user as optional arguments. Do
% it separately for `hl` and `hr` because they each can be different types.
if ~isempty(varargin)
    try %#ok<*TRYNC>
        set(hLhs, varargin{:});
    end
    try
        set(hRhs, varargin{:});
    end
end

setappdata(ax(1), 'IRIS_SERIES', true);
setappdata(ax(1), 'IRIS_FREQ', freqLhs);
setappdata(ax(1), 'IRIS_RANGE', rangeLhs);
setappdata(ax(1), 'IRIS_DATE_POSITION', opt.DatePosition);

setappdata(ax(2), 'IRIS_SERIES', true);
setappdata(ax(2), 'IRIS_FREQ', freqRhs);
setappdata(ax(2), 'IRIS_RANGE', rangeRhs);
setappdata(ax(2), 'IRIS_DATE_POSITION', opt.DatePosition);

if strcmp(lhsPlotFuncStr, 'bar') || strcmp(rhsPlotFuncStr, 'bar')
    setappdata(ax(1), 'IRIS_XLIM_ADJUST', true);
    setappdata(ax(2), 'IRIS_XLIM_ADJUST', true);
end

% Prevent LHS y-axis tick marks on the RHS, and vice versa by turning the
% box off for both axis. To draw a complete box, add a top edge line by
% displaying the x-axis at the top in the first axes object (the x-axis is
% empty, has no ticks or labels).
set(ax, 'Box', 'Off');
set( ax(2), 'Color', 'None', ...
    'XTickLabel', '', ...
    'XTick', [ ], ...
    'XAxisLocation', 'top' );
try
    ax(2).XRuler.Visible = 'on';
end

mydatxtick(ax(1), rangeLhs, timeLhs, freqLhs, userRangeLhs, opt);

% For bkw compatibility only, not documented. Use of `highlight` outside
% `plotyy` is now safe.
if ~isempty(opt.Highlight)
    highlight(ax(1), opt.Highlight);
end

if opt.LhsTight || opt.Tight
    grfun.yaxistight(ax(1));
end

if opt.RhsTight || opt.Tight
    grfun.yaxistight(ax(2));
end

% Make sure the RHS axes object is on the background. We need this for e.g.
% `plotcmp` graphs.
grfun.swaplhsrhs(ax(1), ax(2));

if ~opt.Coincide
    set(ax, 'YTickMode', 'Auto');
end

% Datatip cursor
%----------------
% Store the dates within each plotted object for later retrieval by
% datatip cursor.
for ih = hLhs(:).'
    setappdata(ih, 'IRIS_DATELINE', rangeLhs);
end 
for ih = hRhs(:).'
    setappdata(ih, 'IRIS_DATELINE', rangeRhs);
end

if true % ##### MOSW
    % Use IRIS datatip cursor function in this figure; in
    % utils.datacursor, we also handle cases where the current figure
    % includes both tseries and non-tseries graphs.
    obj = datacursormode(gcf( ));
    set(obj, 'UpdateFcn', @utils.datacursor);
else
    % Do nothing.
end

end%
