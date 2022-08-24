%#ok<*VUNUS>
%#ok<*CTCH>

function varargout = minusControl(varargin)

[varargout{1:nargout}] = databank.backend.control({@minus, @rdivide}, varargin{:});

end%

