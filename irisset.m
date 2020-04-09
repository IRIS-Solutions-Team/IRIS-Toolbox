function varargout = irisset(varargin)

thisWarning = [
    "Deprecated:FunctionName"
    "The function irisset( ) is deprecated and will be removed "
    "from the [IrisToolbox] in a future release. Use iris.set( ) instead."
];
throw(exception.Base(thisWarning, 'warning'));

[varargout{1:nargout}] = iris.set(varargin{:});

end%

