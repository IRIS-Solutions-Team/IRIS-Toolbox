function y = myshift(x,s)

if nargin < 2
   s = -1;
end
xsize = size(x);
x = x(:,:);
[nper,nx] = size(x);
y = [ ];
for k = s(:).'
   if k > 0
      tmp = [x(1+k:end,:);NaN*ones([min([nper,k]),nx])];
   elseif k < 0
      tmp = [NaN*ones([min([-k,nper]),nx]);x(1:end+k,:)];
   else
      tmp = x;
   end
   y = [y,reshape(tmp,xsize)];
end

end
