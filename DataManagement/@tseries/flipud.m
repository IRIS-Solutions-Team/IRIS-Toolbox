function This = flipud(This)
% flipud  Flip time series data up to down.
%
%
% Syntax
% =======
%
%     X = flipud(X)
%
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Time series whose data will be flipped up to down.
%
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Time series with its data flipped up to down.
%
%
% Description
% ============
%
% The data vector or matrix of the input time series is flipped up to down
% using the standard Matlab function `flipud`, i.e. the rows of the data
% vector or matrix are reorganized from last to first.
%
%
% Example
% ========
%
%     >> x = tseries(qq(2000,1):qq(2000,4),1:4)
%     x =
%         tseries object: 4-by-1
%         2000Q1:  1
%         2000Q2:  2
%         2000Q3:  3
%         2000Q4:  4
%         ''
%         user data: empty
%         export files: [0]
%     >> flipud(x)
%     ans =
%         tseries object: 4-by-1
%         2000Q1:  4
%         2000Q2:  3
%         2000Q3:  2
%         2000Q4:  1
%         ''
%         user data: empty
%         export files: [0]
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

This.data = flipud(This.data);

end
