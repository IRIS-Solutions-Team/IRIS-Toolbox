function varargout = size(this, varargin)
% size  Size of time series data
%
% __Syntax__
%
%     S = size(X)
%     [S1, S2, ..., Sn] = size(X)
%
%
% __Input Arguments__
%
% * `X` [ TimeSubscriptable ] - Time series whose size will be returned.
%
%
% __Output Arguments__
%
% * `S` [ numeric ] - Vector of sizes of the time series data in each
% dimension, `S = [S1, S2, ..., Sn]`.
%
% * `S1`, `S2`, ..., `Sn` [ numeric ] - Size of the time series data in
% each dimension.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

[varargout{1:nargout}] = size(this.data, varargin{:});

end
