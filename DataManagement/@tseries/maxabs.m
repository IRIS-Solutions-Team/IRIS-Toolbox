function x = maxabs(x,y)
if nargin > 1
   x = x - y;
end
x = max(abs(x.data(:)));
end