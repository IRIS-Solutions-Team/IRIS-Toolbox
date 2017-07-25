function [X,T] = bpass(X,Band,Range,varargin)
% bpass  Band-pass filter.
%
% Syntax
% =======
%
%     [X,T] = bpass(X,Band,Range,...)
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Band-pass filtered tseries object.
%
% * `T` [ tseries ] - Estimated trend tseries object.
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object that will be filtered.
%
% * `Range` [ numeric | Inf ] Date range on which the data will be
% filtered.
%
% * `Band` [ numeric ] - Band of periodicities to be retained in the output
% data, `Band = [LOW,HIGH]`.
%
% Options
% ========
%
% * `'addTrend='` [ *`true`* | `false` ] - Add the estimated linear time trend
% back to filtered output series if `band` includes Inf.
%
% * `'detrend='` [ *`true`* | `false` ] - Remove an estimated time trend from
% the data before filtering.
%
% * `'log='` [ `true` | *`false`* ] - Logarithmise the data before filtering,
% de-logarithmise afterwards.
%
% * `'method='` [ *`'cf'`* | `'hwfsf'` ] - Type of band-pass filter:
% Christiano-Fitzgerald, or h-windowed frequency-selective filter.
%
% * `'unitRoot='` [ *`true`* | `false` ] - Assume unit root in the input
% data.
%
% See help on [`tseries/trend`](tseries/trend) for other options available
% when `'detrend='` is set to true.
%
% Description
% ============
%
% Christiano, L.J. and T.J.Fitzgerald (2003). The Band Pass Filter.
% International Economic Review, 44(2), 435--465.
%
% Iacobucci, A. & A. Noullez (2005). A Frequency Selective Filter for
% Short-Length Time Series. Computational Economics, 25, 75--102.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if nargin < 3
    Range = Inf;
end

if length(Band) ~= 2 && length(Range) == 2
    % Swap input arguments.
    [Range,Band] = deal(Band,Range);
end

% Parse input arguments.
pp = inputParser( );
pp.addRequired('Band',@(x) isnumeric(x) && length(x) == 2);
pp.addRequired('Range',@isnumeric);
pp.parse(Band,Range);

% Parse options.
[opt,varargin] = passvalopt('tseries.bpass',varargin{:});
trendOpt = passvalopt('tseries.trend',varargin{:});

%--------------------------------------------------------------------------

if isempty(Range) || isnan(X.start)
    X = empty(X);
    T = X;
    return
end

tmpSize = size(X.data);
[xData,Range] = rangedata(X,Range);
xData = xData(:,:);
start = Range(1);

% Run the band-pass filter.
[xData,tData] = tseries.mybpass(xData,start,Band,opt,trendOpt);

% Output data.
X.data = reshape(xData,tmpSize);
X.start = Range(1);
X = trim(X);

% Time trend data.
if nargout > 1
    T = replace(X,reshape(tData,tmpSize));
    T = trim(T);
end

end
