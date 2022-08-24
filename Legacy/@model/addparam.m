function varargout = addparam(varargin)

[varargout{1:nargout}] = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, varargin{:});

end
