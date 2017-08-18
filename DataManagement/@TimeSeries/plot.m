function varargout = plot(varargin)

[varargout{1:nargout}] = implementPlot(@plot, varargin{:});

end
