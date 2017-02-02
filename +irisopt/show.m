function show(varargin)

spl = strsplit(varargin{1}, '.');
x = irisopt.(spl{1});
x = x.(spl{2});
disp(x(1:3:end)');

end
