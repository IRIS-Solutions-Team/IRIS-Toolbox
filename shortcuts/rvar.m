function varargout = rvar(varargin)
% rvar  Shortcut for VAR/estimate.
%
% See help on [`VAR/estimate`](VAR/estimate).
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

[varargout{1:nargout}] = estimate(VAR( ),varargin{:});

end
