% BWF, HPF, LLF

%#ok<*VUNUS>
%#ok<*CTCH>

function varargout = bwf(this, order, varargin)

[varargout{1:nargout}] = implementFilter(order, this, varargin{:});

end%

