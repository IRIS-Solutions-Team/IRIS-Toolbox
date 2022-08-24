function [x, list, range] = db2tseries(d, varargin)
% db2tseries  Combine time series entries from input database in one multivariate time series object.
%
% __Syntax__
%
%     [X, IncludedList, Range] = db2tseries(D, List, Range)
%
%
% __Input Arguments__
%
% * `D` [ struct ] - Input database with tseries objects that will be
% combined in one multivariate tseries object.
%
% * `List` [ char | cellstr ] - List of tseries names that will be
% combined.
%
% * `Range` [ numeric | Inf ] - Date range.
%
%
% __Output Arguments__
%
% * `X` [ numeric ] - Combined multivariate tseries object.
%
% * `IncludedList` [ cellstr ] - List of time series names that have been
% actually included in the output time series.
%
% * `Range` [ numeric ] - Date range actually used.
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

[x, list, range] = db2array(d, varargin{:});
x = Series(range, x);

end%

