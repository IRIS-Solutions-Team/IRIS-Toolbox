function d = maxabsinf(x,y)
if nargin > 1
   x = x - y;
end
x = x(:);
x(isinf(x)) = [ ];
d = max(abs(x));
end