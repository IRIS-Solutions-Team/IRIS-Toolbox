function x = divisia(x,w,range)
% divisia  Discrete Divisia index.
%
% Syntax
% =======
%
%     Y = divisia(X,W,RANGE)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input times series.
%
% * `W` [ tseries | numeric ] - Fixed or time-varying weights on the input
% time series.
%
% * `RANGE` [ numeric ] - Range on which the Divisia index is computed.
%
% Output arguments
% =================
%
% * `Y` [ tseries ] - Discrete divisia index based on `X` and `W`.
%
% Description
% ============
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

if nargin < 3
   range = Inf;
end

% For backward compatibility, accept divisia(x,range,w),
% and swap w and range.
if isnumeric(w) && (any(isinf(w)) || (size(w,1) == 1 && size(w,2) ~= size(x,2)))
   [w,range] = deal(range,w);
end

%**************************************************************************

x = windex(x,w,range,'method','divisia');

end