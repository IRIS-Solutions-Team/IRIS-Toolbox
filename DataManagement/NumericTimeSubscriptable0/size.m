function varargout = size(this, varargin)

[varargout{1:nargout}] = size(this.data, varargin{:});

end%
