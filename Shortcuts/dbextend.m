function varargout = dbextend(varargin)
[varargout{1:nargout}] = dboverlay(varargin{:});
end