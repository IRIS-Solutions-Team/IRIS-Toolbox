
function varargout = dbminuscontrol(varargin)

exception.warning([
    "Deprecated"
    "Function dbminuscontrol is deprecated, and will be removed in the near future."
    "Use databank.minusControl instead."
]);

[varargout{1:nargout}] = databank.minusControl(varargin{:});

end%

