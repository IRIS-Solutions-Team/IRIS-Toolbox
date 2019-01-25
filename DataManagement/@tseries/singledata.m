function x = singledata(x)
% singledata  Convert tseries observations to single precision.
%
% Syntax
% =======
%
%     x = singledata(x)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Tseries object whose observations will be be
% converted to single precision.
%
% Output arguments
% =================
%
% * `y` [ numeric ] - Tseries object with single-precision observations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%**************************************************************************

x.data = single(x.data);

end