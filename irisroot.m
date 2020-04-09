function varargout = irisroot(varargin)

thisWarning = [
    "Deprecated:FunctionName"
    "The function irisroot( ) is deprecated and will be removed "
    "from the [IrisToolbox] in a future release. Use iris.root( ) instead."
];
throw(exception.Base(thisWarning, 'warning'));

[varargout{1:nargout}] = iris.root(varargin{:});

end%

