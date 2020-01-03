function This = permute(This,Order)
% permute  Permute dimensions of a tseries object.
%
%
% Syntax
% =======
%
%     X = permute(X,Order)
%
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object whose dimensions, except the first
% (time) dimension, will be rearranged in the order specified by the vector
% `order`.
%
% * `Order` [ numeric ] - New order of dimensions; because the time
% dimension cannot be permuted, `order(1)` must be always `1`.
%
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output tseries object with its dimensions permuted.
%
%
% Description
% ============
%
% See help on the standard Matlab function `permute`.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('X',@(x) isa(x,'tseries'));
pp.addRequired('Order',@(x) isnumeric(x) && ~isempty(x) && x(1) == 1);
pp.parse(This,Order);

%--------------------------------------------------------------------------

This.data = permute(This.data,Order);
This.Comment = permute(This.Comment,Order);

end
