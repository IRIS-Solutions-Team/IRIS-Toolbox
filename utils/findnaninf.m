function index = findnaninf(list,x,varargin)

if isnan(x)
   index = find(isnan(list),varargin{:});
elseif isinf(x)
   index = find(isinf(list),varargin{:});
else
   index = find(list == x,varargin{:});
end

end