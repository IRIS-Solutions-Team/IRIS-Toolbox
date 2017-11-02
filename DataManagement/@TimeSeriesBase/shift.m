function this = shift(this, sh)
% shift  Shift times series by a lag or lead
%
% __Syntax__
%
%     X = shift(X, Sh)
%
%
% __Input Arguments__
%
% * `X` [ TimeSeriesBase ] - Input time series.
%
% * `Sh` [ numeric ] - Lag (a negative number) or lead (a positive number)
% by which the time series will be shifted.
%
%
% __Output Arguments__
%
% `X` [TimeSeriesBase ] - Shifted time series.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

this.Start = addTo(this.Start, -sh);

end
