function flag = isscalar(x)

flag = ndims(x.data) == 2 && size(x.data,2) == 1;

end
