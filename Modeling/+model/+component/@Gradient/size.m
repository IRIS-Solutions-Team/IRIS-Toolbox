function varargout = size(this)

n = size(this.Dynamic, 2);
if nargout==1
    varargout{1} = [1, n];
else
    varargout = {1, n};
end

end%

