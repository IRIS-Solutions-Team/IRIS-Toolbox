function varargout = vertcat(varargin)
[varargout{1:nargout}] = horzcat(varargin{:});
end