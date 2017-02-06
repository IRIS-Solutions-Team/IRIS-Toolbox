function [x, list, range] = db2tseries(d, varargin)
% db2tseries  Combine time series entries from input database in one multivariate time series object.
%
% Syntax
% =======
%
%     [x, includedList, range] = db2tseries(d, list, range)
%
%
% Input arguments
% ================
%
% * `d` [ struct ] - Input database with tseries objects that will be
% combined in one multivariate tseries object.
%
% * `list` [ char | cellstr ] - List of tseries names that will be
% combined.
%
% * `range` [ numeric | Inf ] - Date range.
%
%
% Output arguments
% =================
%
% * `x` [ numeric ] - Combined multivariate tseries object.
%
% * `includedList` [ cellstr ] - List of time series names that have been
% actually included in the output time series.
%
% * `range` [ numeric ] - Date range actually used.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[x, list, range] = db2array(d, varargin{:});
x = Series(range, x);

end
