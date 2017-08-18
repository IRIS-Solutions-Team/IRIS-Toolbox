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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isempty(varargin) && DateWrapper.validateDateInput(varargin{1})
    range = varargin{1};
    varargin(1) = [ ];
    if ischar(range)
        range = textinp2dat(range);
    end
else
    range = @all;
end

% Parse options.
opt = passvalopt('tseries.trend', varargin{:});

%--------------------------------------------------------------------------

[data, range] = rangedata(this, range);
size_ = size(data);
data = data(:, :);

% Compute the trend.
[data, ttData, tsData] = tseries.mytrend(data, range(1), opt);
data = reshape(data, size_);

% Output data.
this = replace(this, data, range(1));
this = trim(this);
if nargout>1
    tt = replace(this, reshape(ttData, size_));
    tt = trim(tt);
    if nargout>2
        ts = replace(this, reshape(tsData, size_));
        ts = trim(ts);
    end
end

end
