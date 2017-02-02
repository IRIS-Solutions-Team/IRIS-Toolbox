function d = maxabs0(x,y)
x(isnan(x)) = 0;
if nargin > 1
    y(isnan(x)) = 0;
    x = x - y;
end
d = max(abs(x(:)));
end