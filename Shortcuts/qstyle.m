function varargout = qstyle(varargin)
% qplot  Shortcut for qreport.qstyle.
%
% See help on [`qreport.qstyle`](qreport/qstyle).

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = qreport.qstyle(varargin{:});

end
