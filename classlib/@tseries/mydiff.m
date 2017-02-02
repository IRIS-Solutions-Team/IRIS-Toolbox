function x = mydiff(x,s)

if nargin < 2
    s = -1;
end
s = s(:).';
index = transpose(1:size(x,2));
index = index(:,ones([1,length(s)]));
index = transpose(index(:));
x = x(:,index) - tseries.myshift(x,s);

end