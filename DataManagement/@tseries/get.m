function varargout = get(this, varargin)
% get  Query tseries object property.
%
% Syntax
% =======
%
%     Ans = get(X, Query)
%     [Ans, Ans, ...] = get(X, Query, Query, ...)
%
%
% Input arguments
% ================
%
% * `X` [ model ] - Tseries object.
%
% * `Query` [ char ] - Query to the tseries object.
%
%
% Output arguments
% =================
%
% * `Ans` [ ... ] - Answer to the query.
%
%
% Valid queries to tseries objects
% =================================
%
% * `'End='` Returns [ numeric ] the date of the last observation.
%
% * `'Freq='` Returns [ numeric ] the frequency (periodicity) of the time
% series.
%
% * `'NanEnd='` Returns [ numeric ] the last date at which observations are
% available in all columns; for scalar tseries, this query always returns
% the same as `'end'`.
%
% * `'NanRange='` Returns [ numeric ] the date range from `'nanstart'` to
% `'nanend'`; for scalar time series, this query always returns the same as
% `'range'`.
%
% * `'NanStart='` Returns [ numeric ] the first date at which observations are
% available in all columns; for scalar tseries, this query always returns
% the same as `'start'`.
%
% * `'Range='` Returns [ numeric ] the date range from the first observation to the
% last observation.
%
% * `'Start='` Returns [ numeric ] the date of the first observation.
%
%
% Description
% ============
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

P = inputParser( );
P.addRequired('Query', @iscellstr);
P.parse(varargin);

%--------------------------------------------------------------------------

[varargout{1:nargout}] = get@shared.GetterSetter(this, varargin{:});

end
