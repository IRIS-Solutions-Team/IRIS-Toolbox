function This = detrend(This,varargin)
% detrend  Remove a linear time trend.
%
% Syntax
% =======
%
%     X = detrend(X,...)
%     X = detrend(X,Range,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input time series.
%
% * `Range` [ numeric | `@all` | char ] - The date range on which the trend
% will be computed; `@all` means the entire range available will be used.
%
% Output arguments
% =================
%
% * `x` [ tseries ] - Output time series with a trend removed.
%
% Options
% ========
%
% See [`tseries/trend`](tseries/trend) for options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

This = This - trend(This,varargin{:});

end
