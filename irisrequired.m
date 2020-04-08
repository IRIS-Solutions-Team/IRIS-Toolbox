function varargout = irisrequired(varargin)

thisWarning = [
    "Deprecated:FunctionName"
    "The function irisrequired( ) is deprecated and will be removed "
    "from the [IrisToolbox] in a future release. Use iris.required( ) instead."
];

[varargout{1:nargout}] = iris.required(varargin{:});

end%

