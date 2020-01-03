function varargout = conbar(varargin)
% conbar  Alias for BARCON.
%
% See help on [`tseries/barcon`](tseries/barcon).

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

% AREA, BAR, PLOT, CONBAR, PLOTYY, STEM

%--------------------------------------------------------------------------

[varargout{1:nargout}] = barcon(varargin{:});

end