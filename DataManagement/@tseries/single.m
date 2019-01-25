function y = single(x)
% single  Return tseries observations as single-precision numeric array.
%
% Syntax
% =======
%
%     y = single(x)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Tseries object whose observations will be returned as
% single-precision numeric array.
%
% Output arguments
% =================
%
% * `y` [ numeric ] - Single-precision numeric array with the input tseries
% observations in columns.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

y = single(x.data);

end