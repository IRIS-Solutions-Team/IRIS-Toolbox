function x = doubledata(x)
% doubledata  Convert tseries observations to double precision.
%
% Syntax
% =======
%
%     x = doubledata(x)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Tseries object whose observations will be be
% converted to double precision.
%
% Output arguments
% =================
%
% * `y` [ numeric ] - Tseries object with double-precision observations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

%**************************************************************************

x.data = double(x.data);

end
