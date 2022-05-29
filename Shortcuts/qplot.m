function varargout = qplot(varargin)
% qplot  Shortcut for qreport.qplot.
%
% See help on [`qreport.qplot`](qreport/qplot).

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = qreport.qplot(varargin{:});

end
