function n = length(this)
% length  Length of time series data in time dimension
%
% __Syntax__
%
%     N = length(X)
%
% __Input Arguments__
%
% * `x` [ tseries ] Time series object.
%
%
% __Output Arguments__
%
% * `N` [ numeric ] - Number of periods from the first to the last
% available observation in the input tseries object.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

n = size(this.Data, 1);

end
