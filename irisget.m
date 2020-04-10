function varargout = irisget(varargin)

thisWarning = [
    "Deprecated:FunctionName"
    "The function irisget( ) is deprecated and will be removed "
    "from the [IrisToolbox] in a future release. Use iris.get( ) instead."
];
throw(exception.Base(thisWarning, 'warning'));

[varargout{1:max(nargout, 1)}] = iris.get(varargin{:});

end%

