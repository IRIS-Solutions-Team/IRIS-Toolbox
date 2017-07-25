function [x,ss] = reshape(x,s)
% reshape  Reshape size of time series in 2nd and higher dimensions.
%
% Syntax
% =======
%
%     x = reshape(x,newsize)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Tseries object whose data will be reshaped in 2nd
% and/or higher dimensions.
%
% * `newsize` [ numeric ] - New size of the tseries object data; the first
% dimension (time) must be preserved.
%
% Output arguments
% =================
%
% * `x` [ tseries ] - Reshaped tseries object.
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

ss = size(x.data);
if nargin < 2
   s = prod(ss(2:end));
else
   if ~isinf(s(1)) && s(1) ~= ss(1)
      utils.error('tseries:reshape', ...
         'First dimension of tseries objects must remain unchanged after RESHAPE.');
   end
   s(1) = ss(1);
end

% Reshape data and comments.
x.data = reshape(x.data,s);
x.Comment = reshape(x.Comment,[1,s(2:end)]);

end
