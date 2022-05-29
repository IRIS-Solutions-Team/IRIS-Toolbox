function varargout = predplot(varargin)
% predplot  Shortcut for tseries/plotpred.
%
% See help on [`tseries/plotpred`](tseries/plotpred).
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

[varargout{1:nargout}] = plotpred(varargin{:});

end
