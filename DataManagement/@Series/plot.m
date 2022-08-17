
function varargout = plot(varargin)

    [varargout{1:nargout}] = Series.implementPlot(@plot, varargin{:});

end%

