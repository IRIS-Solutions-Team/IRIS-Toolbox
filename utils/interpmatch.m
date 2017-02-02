function y2 = interpmatch(y1,n)

[nobs,ny] = size(y1);
y2 = nan([nobs*n,ny]);

t1 = (1 : n)';
t2 = (n+1 : 2*n)';
t3 = (2*n+1 : 3*n)';
M = [...
   n, sum(t1), sum(t1.^2);...
   n, sum(t2), sum(t2.^2);...
   n, sum(t3), sum(t3.^2);...
];

for i = 1 : ny
  yy = [ y1(1:end-2), y1(2:end-1), y1(3:end) ]';
  b = nan([3,nobs]);
  b(:,2:end-1) = M \ yy;
  y2i = nan([n,nobs]);
  for t = 2 : nobs-1
     y2i(:,t) = b(1,t)*ones([n,1]) + b(2,t)*t2 + b(3,t)*t2.^2;
  end
  y2i(:,1) = b(1,2) + b(2,2)*t1 + b(3,2)*t1.^2;
  y2i(:,end) = b(1,end-1) + b(2,end-1)*t3 + b(3,end-1)*t3.^2;
  y2(:,i) = y2i(:);
end

end