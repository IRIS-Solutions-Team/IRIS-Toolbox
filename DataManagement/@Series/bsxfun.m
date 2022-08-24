function X = bsxfun(Func, X, Y)

% Validate input arguments.
pp = inputParser( );
pp.addRequired('Func', @(x) isa(x, 'function_handle'));
pp.addRequired('X', @(x) isa(x, 'Series') || isnumeric(x));
pp.addRequired('Y', @(x) isa(x, 'Series') || isnumeric(x));
pp.parse(Func, X, Y);

if isa(X, 'Series') && isa(Y, 'Series')
    minStart = min(double(X.Start), double(Y.Start));
    maxEnd = max(X.EndAsNumeric, Y.EndAsNumeric);
    data1 = getDataFromTo(X, minStart, maxEnd);
    data2 = getDataFromTo(Y, minStart, maxEnd);
    nPer = dater.rangeLength(minStart, maxEnd); 
    newCmt = [ ];
    newStart = minStart;
elseif isa(X, 'Series')
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

if isa(X, 'Series')
    X = replace(X, newData, newStart, newCmt);
else
    X = replace(Y, newData, newStart, newCmt);
end

end%

