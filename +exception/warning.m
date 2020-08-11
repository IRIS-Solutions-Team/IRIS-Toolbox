function warning(specs, varargin)
    throw(exception.Base(specs, "warning"), varargin{:});
end%

