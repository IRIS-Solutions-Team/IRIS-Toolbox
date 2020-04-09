function irisstartup(varargin)

iris.startup('--tseries', varargin{:});

thisWarning = [
    "Deprecated:FunctionName"
    "The function irisstartup( ) is deprecated and will be removed "
    "from the [IrisToolbox] in a future release. Use iris.startup( ) instead."
];
throw(exception.Base(thisWarning, 'warning'));

end%

