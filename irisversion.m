function varargout = irisversion(varargin)

thisWarning = [
    "Deprecated:FunctionName"
    "The function irisversion( ) is deprecated and will be removed "
    "from the [IrisToolbox] in a future release. Use iris.release( ) instead."
];
throw(exception.Base(thisWarning, 'warning'));

[varargout{1:nargout}] = iris.release(varargin{:});

end%

