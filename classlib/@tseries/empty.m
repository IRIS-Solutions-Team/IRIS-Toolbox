function This = empty(This)
% empty  Empty time series preserving the size in 2nd and higher dimensions.
%
% Syntax
% =======
%
%     x = empty(x)
%
% Input arguments
% ================
%
% * `This` [ tseries ] - Input time series that will be emptied.
%
% Output arguments
% =================
%
% * `This` [ tseries ] - Empty time series with the 2nd and higher
% dimensions the same size as the input tseries object, and comments
% preserved.
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

This.start = NaN;
s = size(This.data);
s(1) = 0;
This.data = zeros(s);
% Comments are preserved.

end
