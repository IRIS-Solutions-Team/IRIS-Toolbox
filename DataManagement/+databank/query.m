function varargout = query(varargin)
[varargout{1:nargout}] = databank.filter(varargin{:});
end%

