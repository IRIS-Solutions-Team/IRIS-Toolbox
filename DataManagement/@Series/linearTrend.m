function this = linearTrend(range, varargin)
% linearTrend  Create time series with linear trend
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     x = Series.linearTrend(range, ~step, ~startValue)
%
%
% __Input Arguments__
%
% * `range` [ DateWrapper ] - Date range on which the trend time series
% will be created.
%
% * `~step=1` [ numeric ] - Difference between two consecutive dates in the
% trend; if omitted, the increment of the trend will be 1.
%
% * `~startValue=0` [ numeric ] - Starting value for the trend; if omitted, the
% trend will startValue at zero.
%
%
% __Output Arguments__
%
% * `x` [ Series ] - Output time series with a linear trend.
%
%
% __Description__
%
%
% __Example__
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

this = NumericTimeSubscriptable.linearTrend(@Series, range, varargin{:});

end%

