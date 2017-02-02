function varargout = outside(varargin)
warning('OUTSIDE is an obsolete function name. Use REPORTING instead.');
[varargout{1:nargout}] = reporting(varargin{:});
end