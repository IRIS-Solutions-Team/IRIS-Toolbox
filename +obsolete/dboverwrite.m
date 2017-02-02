function varargout = dboverwrite(varargin)

% function body ---------------------------------------------------------------------------------------------

warning('iris:obsolete','DBOVERWRITE is an obsolete function name. Use DBOVERLAY instead.');
[varargout{1:nargout}] = dboverlay(varargin{:});

end % of primary function -----------------------------------------------------------------------------------