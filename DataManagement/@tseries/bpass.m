% bpass  Band-pass filter
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [X, T] = bpass(X, Band, ~Range, ...)
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
% * `Band` [ numeric ] - Band of periodicities to be retained in the output
% data, `Band = [Low, High]`.
%
% * `~Range=Inf` [ Dater ] - Date range on which the data will be
% filtered; if omitted, the entire time series range will be used.
%
%
% __Options__
%
% * `AddTrend=true` [ `true` | `false` ] - Add the estimated linear time
%  trend back to filtered output series if `band` includes `Inf`.
%
% * `Detrend=true` [ `true` | `false` | cell ] - Remove an estimated time
%  trend from the data before filtering; specify options for detrending in
%  a cell array; see [`trend`](tseries/trend).
%
% * `Log=false` [ `true` | `false` ] - Logarithmize the data before
%  filtering, de-logarithmize afterwards.
%
% * `Method='cf'` [ `'cf'` | `'hwfsf'` ] - Type of band-pass filter:
% Christiano-Fitzgerald, or h-windowed frequency-selective filter.
%
% * `UnitRoot=true` [ `true` | `false` ] - Assume unit root in the input
% data.
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
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function [this, trend] = bpass(this, band, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('tseries.bpass');
    pp.KeepUnmatched = true;
    pp.addRequired('InputSeries', @(x) isa(x, 'TimeSubscriptable'));
    pp.addRequired('Band', @(x) isnumeric(x) && numel(x)==2);
    pp.addOptional('Range', Inf, @validate.range);
end
parse(pp, this, band, varargin{:});
range = double(pp.Results.Range);
unmatched = pp.UnmatchedInCell;

%--------------------------------------------------------------------------

if isempty(range) || isnan(this.Start) || isempty(this.Data)
    this = this.empty(this);
    trend = this;
    return
end

[inputData, startDate] = getDataFromTo(this, range);

% Run the band-pass filter
[filterData, trendData] = numeric.bpass( ...
    inputData, band, ...
    'StartDate', startDate, ...
    unmatched{:} ...
);

% Output data
this.Data = filterData;
this.Start = startDate;
this = trim(this);

% Time trend data
if nargout>1
    trend = fill(this, trendData);
    trend = trim(trend);
end

end%

