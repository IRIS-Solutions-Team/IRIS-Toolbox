function X = bsxfun(Func, X, Y)
% bsxfun  Implement bsxfun for tseries class.
%
%
% Syntax
% =======
%
%     Z = bsxfun(Func, X, Y)
%
%
% Input arguments
% ================
%
% * `Func` [ function_handle ] - Function that will be applied to the input
% series, `FUN(X, Y)`.
%
% * `X` [ Series | numeric ] - Input time series or numeric array.
%
% * `Y` [ Series | numeric ] - Input time series or numeric array.
%
%
% Output arguments
% =================
%
% * `Z` [ tseries ] - Result of `Func(X, Y)` with `X` and/or `Y` expanded
% properly in singleton dimensions.
%
%
% Description
% ============
%
% See help on built-in `bsxfun` for more help.
%
%
% Example
% ========
%
% Create a multivariate time series and subtract mean from its
% individual columns.
%
%     x = Series(1:10, rand(10, 4));
%     xx = bsxfun(@minus, x, mean(x));
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Validate input arguments.
pp = inputParser( );
pp.addRequired('Func', @isfunc);
pp.addRequired('X', @(x) isa(x, 'tseries') || isnumeric(x));
pp.addRequired('Y', @(x) isa(x, 'tseries') || isnumeric(x));
pp.parse(Func, X, Y);

%--------------------------------------------------------------------------

if isa(X, 'TimeSubscriptable') && isa(Y, 'TimeSubscriptable')
    minStart = min(double(X.Start), double(Y.Start));
    maxEnd = max(X.EndAsNumeric, Y.EndAsNumeric);
    data1 = getDataFromTo(X, minStart, maxEnd);
    data2 = getDataFromTo(Y, minStart, maxEnd);
    nPer = dater.rangeLength(minStart, maxEnd); 
    newCmt = [ ];
    newStart = minStart;
elseif isa(X, 'TimeSubscriptable')
    data1 = X.Data;
    data2 = Y;
    nPer = size(X.Data, 1);
    newCmt = X.Comment;
    newStart = X.Start;
else
    data1 = X;
    data2 = Y.Data;
    nPer = size(Y.Data, 1);
    newCmt = Y.Comment;
    newStart = Y.Start;
end

newData = bsxfun(Func, data1, data2);

if size(newData, 1)~=nPer
    utils.error('tseries:bsxfun', ...
        ['Result of bsxfun(...) must preserve ', ...
        'the size of input tseries in 1st dimension.']);
end

if isa(X, 'TimeSubscriptable')
    X = replace(X, newData, newStart, newCmt);
else
    X = replace(Y, newData, newStart, newCmt);
end

end%

