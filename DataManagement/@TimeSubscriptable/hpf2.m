function varargout = hpf2(varargin)

n = max(2, nargout);
[varargout{1:n}] = hpf(varargin{:});
varargout([1, 2]) = varargout([2, 1]); %#ok<VARARG>

end%
