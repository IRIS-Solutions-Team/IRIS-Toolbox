function x = mynansum(x,dim)

if dim > ndims(x)
    return
end
index = ~isnan(x);
x(~index) = 0;
x = sum(x,dim);

end
