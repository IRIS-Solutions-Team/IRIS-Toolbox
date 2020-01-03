function this = detrend(this, varargin)
% detrend  Remove linear time trend from time series data.
%
% Syntax
% =======
%
% Input arguments marked with a `~` sign may be omitted.
%
%     x = detrend(x, ~range,...)
%
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Input time series.
%
% * `~range` [ numeric | `@all` | char ] - The date range on which the
% trend will be computed; if omitted or assigned `@all`, the entire range
% available will be used.
%
%
% Output arguments
% =================
%
% * `x` [ tseries ] - Output time series with a trend removed.
%
%
% Options
% ========
%
% See [`tseries/trend`](tseries/trend) for options available.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

this = this - trend(this, varargin{:});

end
