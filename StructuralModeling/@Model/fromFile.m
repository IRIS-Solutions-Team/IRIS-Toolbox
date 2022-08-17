function varargout = fromFile(fileName, varargin)

source = ModelSource.fromFile(fileName, varargin{:});
[varargout{1:nargout}] = Model(source, varargin{:});

end%

