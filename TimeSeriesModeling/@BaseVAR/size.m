
function varargout = size(this, varargin)

    temp = true(1, countVariants(this));
    [varargout{1:nargout}] = size(temp, varargin{:});

end%
