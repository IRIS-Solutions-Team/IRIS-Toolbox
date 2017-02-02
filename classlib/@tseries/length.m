function n = length(x)
% length  Length of tseries object.
%
% Syntax
% =======
%
%     n = length(x)
%
% Input arguments
% ================
%
% * `x` [ tseries ] Tseries object.
%
% Output arguments
% =================
%
% * `n` [ numeric ] - Number of periods from the first to the last
% available observation in the input tseries object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%**************************************************************************

n = size(x.data,1);

end