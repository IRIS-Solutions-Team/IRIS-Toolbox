function varargout = conlegend(varargin)

warning('iris:obsolete', ...
   ['CONLEGEND is no longer needed, and ',...
   'will be removed from future versions of IRIS. ',...
   'Use the standard LEGEND function to annotate CONBAR graphs.']);
[varargout{1:nargout}] = legend(varargin{:});

end