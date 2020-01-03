function [this, tt, ts] = trend(this, varargin)
% trend  Estimate time trend in time series data.
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     x = trend(x, ~range, ...)
%
%
% __Input arguments__
%
% * `x` [ tseries ] - Input time series.
%
% * `~range` [ numeric | `@all` | char ] - Range for which the trend will be
% computed; if omitted or assigned `@all`, the entire range of the input times series.
%
%
% __Output arguments__
%
% * `x` [ tseries ] - Output trend time series.
%
%
% __Options__
%
% * `'Break='` [ numeric | *empty* ] - Vector of breaking points at which
% the trend may change its slope.
%
% * `'Connect='` [ *`true`* | `false` ] - Calculate the trend by connecting
% the first and the last observations.
%
% * `'Diff='` [ `true` | *`false`* ] - Estimate the trend on differenced
% data.
%
% * `'Log='` [ `true` | *`false`* ] - Logarithmize the input data, 
% de-logarithmize the output data.
%
% * `'Season='` [ `true` | *`false`* | `2` | `4` | `6` | `12` ] - Include
% deterministic seasonal factors in the trend.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

if ~isempty(varargin) && DateWrapper.validateDateInput(varargin{1})
    range = varargin{1};
    varargin(1) = [ ];
    if ischar(range)
        range = textinp2dat(range);
    end
else
    range = @all;
end

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.trend');
    inputParser.KeepUnmatched = true;
    inputParser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    inputParser.addOptional('Range', Inf, @DateWrapper.validateRangeInput);
end
inputParser.parse(this, varargin{:});
opt = inputParser.Options;
trendOpt = inputParser.UnmatchedInCell;

%--------------------------------------------------------------------------

[data, range] = rangedata(this, range);
if isempty(range)
    this = this.empty(this);
    return
end
startDate = range(1);

sizeData = size(data);
ndimsData = ndims(data);
data = data(:, :);

[data, tt, ts] = numeric.trend(data, 'StartDate=', startDate, trendOpt{:});

if ndimsData>2
    data = reshape(data, sizeData);
    tt = reshape(tt, sizeData);
    ts = reshape(ts, sizeData);
end

% Output data
this = replace(this, data, range(1));
this = trim(this);
if nargout>1
    tt = replace(this, tt, range(1));
    if nargout>2
        ts = replace(this, ts, range(1));
    end
end

end
