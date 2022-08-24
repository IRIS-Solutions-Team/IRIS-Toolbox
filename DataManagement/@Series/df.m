function varargout = df(varargin)

[varargout{1:nargout}] = diff(varargin{:});

end
