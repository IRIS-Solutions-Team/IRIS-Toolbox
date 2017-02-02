function varargout = emptycellstr(varargin)
if length(varargin) == 1
    varargout{1} = cell(varargin{1});
else
    varargout{1} = cell(varargin{:});
end
varargout{1}(:) = {''};
end