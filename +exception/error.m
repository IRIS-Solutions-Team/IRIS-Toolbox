function error(specs, varargin)
    throw(exception.Base(specs, "error"), varargin{:});
end%

