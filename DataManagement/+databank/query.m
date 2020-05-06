function varargout = query(varargin)
thisWarning = [ 
    "IrisToolbox:Deprecated"
    "Function databank.query is a deprecated function name, and will be discontinued "
    "in a future release of the [IrisToolbox]. Use databank.filter instead."
];
throw(exception.Base(thisWarning, 'warning'));

[varargout{1:nargout}] = databank.filter(varargin{:});
end%

