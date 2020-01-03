function varargout = df(varargin)
% df  Alias for diff.
%
% See help on [`tseries/diff`](tseries/diff).


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = diff(varargin{:});

end