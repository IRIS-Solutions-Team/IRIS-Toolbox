function varargout = estimate(varargin)
warning('iris:obsolete','MAXLOGLIK is an obsolete function name. Use ESTIMATE instead.');
[varargout{1:nargout}] = estimate(varargin{:});
end