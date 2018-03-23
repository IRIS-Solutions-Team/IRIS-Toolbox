function x = plus(x,y)
if ischar(x)
  x = {x};
end
if ischar(y)
  y = {y};
end
x = union(x,y);
end