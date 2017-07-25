function y = myshift(x, s)

if nargin<2
   s = -1;
end
size_ = size(x);
x = x(:, :);
[nPer, nx] = size(x);
y = [ ];
for k = s(:).'
   if k>0
      tmp = [x(1+k:end, :); nan([min([nPer, k]), nx])];
   elseif k<0
      tmp = [nan([min([-k, nPer]), nx]); x(1:end+k, :)];
   else
      tmp = x;
   end
   y = [y, reshape(tmp, size_)];
end

end
