function varargout = hpf(varargin)

order = 2;
[varargout{1:nargout}] = implementFilter(order, varargin{:});

end%
