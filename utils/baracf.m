function handle = baracf(c,x,y,varargin)

order = size(c,3) - 1;
c1 = c(x,y,end:-1:1);
c2 = c(y,x,2:end);
aux = [c1(:);c2(:)]';
handle = bar(-order:order,aux,varargin{:});

end