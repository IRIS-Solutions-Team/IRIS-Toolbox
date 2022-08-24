function varargout = bwf2(varargin)
% BWF2, HPF2, LLF2

n = max(2, nargout);
[varargout{1:n}] = bwf(varargin{:});
varargout([1, 2]) = varargout([2, 1]); %#ok<VARARG>

end%

