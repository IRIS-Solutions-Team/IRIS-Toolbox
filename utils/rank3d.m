function x = rank3d(X)

n = size(X,3);
x = nan([1,n]);
for i = 1 : n
   index = ~all(isnan(X(:,:,i)),1);
   x(i) = rank(X(index,index,i));
end

end