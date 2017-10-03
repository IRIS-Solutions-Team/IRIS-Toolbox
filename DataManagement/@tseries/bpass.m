function [this, trend] = bpass(this, band, range, varargin)
% bpass  Band-pass filter.
%
% __Syntax__
%
%     [X, T] = bpass(X, Band, Range, ...)
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Band-pass filtered tseries object.
%
% * `T` [ tseries ] - Estimated trend tseries object.
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input tseries object that will be filtered.
%
% * `Range` [ numeric | Inf ] Date range on which the data will be
% filtered.
%
% * `Band` [ numeric ] - Band of periodicities to be retained in the output
% data, `Band = [LOW, HIGH]`.
%
%
% __Options__
%
% * `'AddTrend='` [ *`true`* | `false` ] - Add the estimated linear time trend
% back to filtered output series if `band` includes Inf.
%
% * `'Detrend='` [ *`true`* | `false` ] - Remove an estimated time trend from
% the data before filtering.
%
% * `'Log='` [ `true` | *`false`* ] - Logarithmise the data before filtering, 
% de-logarithmise afterwards.
%
% * `'Method='` [ *`'cf'`* | `'hwfsf'` ] - Type of band-pass filter:
% Christiano-Fitzgerald, or h-windowed frequency-selective filter.
%
% * `'UnitRoot='` [ *`true`* | `false` ] - Assume unit root in the input
% data.
%
% See help on [`tseries/trend`](tseries/trend) for other options available
% when `'detrend='` is set to true.
%
%
% __Description__
%
% Christiano, L.J. and T.J.Fitzgerald (2003). The Band Pass Filter.
% International Economic Review, 44(2), 435--465.
%
% Iacobucci, A. & A. Noullez (2005). A Frequency Selective Filter for
% Short-Length Time Series. Computational Economics, 25, 75--102.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if nargin<3
    range = Inf;
end

if length(band)~=2 && length(range)==2
    % Swap input arguments.
    [range, band] = deal(band, range);
end

% Parse input arguments.
pp = inputParser( );
pp.addRequired('Band', @(x) isnumeric(x) && length(x)==2);
pp.addRequired('Range', @isnumeric);
pp.parse(band, range);

% Parse options.
[opt, varargin] = passvalopt('tseries.bpass', varargin{:});
trendOpt = passvalopt('tseries.trend', varargin{:});

%--------------------------------------------------------------------------

if isempty(range) || isnan(this.Start)
    this = this.empty(this);
    trend = this;
    return
end

sizeOfInputData = size(this.Data);
[inputData, range] = rangedata(this, range);
inputData = inputData(:, :);
start = range(1);

% Run the band-pass filter.
[filterData, trendData] = tseries.mybpass(inputData, start, band, opt, trendOpt);

% Output data.
this.Data = reshape(filterData, sizeOfInputData);
this.Start = range(1);
this = trim(this);

% Time trend data.
if nargout>1
    trend = replace(this, reshape(trendData, sizeOfInputData));
    trend = trim(trend);
end

end
