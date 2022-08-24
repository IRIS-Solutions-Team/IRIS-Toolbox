%#ok<*VUNUS>
%#ok<*CTCH>

function varargout = plusControl(varargin)

[varargout{1:nargout}] = databank.backend.control({@plus, @times}, varargin{:});

end%

