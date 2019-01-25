function [this, trend] = bpass(this, band, varargin)
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
% * `~Range=Inf` [ DateWrapper ] - Date range on which the data will be
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
% -Copyright (c) 2007-2019 IRIS Solutions Team.

% Legacy input arguments
if nargin>=3 && ~ischar(varargin{1})
    range = varargin{1};
    if length(band)~=2 && length(range)==2
        % Swap input arguments
        % ##### Feb 2018 OBSOLETE and scheduled for removal
        throw( exception.Base('Obsolete:BPassInputs', 'warning') );
        [range, band] = deal(band, range);
        varargin{1} = range;
    end
end

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.bpass');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    inputParser.addRequired('Band', @(x) isnumeric(x) && numel(x)==2);
    inputParser.addOptional('Range', Inf, @DateWrapper.validateRangeInput);
end
inputParser.parse(this, band, varargin{:});
range = inputParser.Results.Range;
unmatched = inputParser.UnmatchedInCell;

%--------------------------------------------------------------------------

if isempty(range) || isnan(this.Start) || isempty(this.Data)
    this = this.empty(this);
    trend = this;
    return
end

[inputData, range] = rangedata(this, range);
startDate = range(1);

% Run the band-pass filter
[filterData, trendData] = numeric.bpass( ...
    inputData, band, ...
    'StartDate=', startDate, ...
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

end
