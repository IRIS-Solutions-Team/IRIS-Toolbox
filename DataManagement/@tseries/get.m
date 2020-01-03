function varargout = get(this, varargin)
% get  Query tseries object property
%
% __Syntax__
%
%     Ans = get(X, Query)
%     [Ans, Ans, ...] = get(X, Query, Query, ...)
%
%
% __Input Arguments__
%
% * `X` [ model ] - Queried time series.
%
% * `Query` [ char ] - Query.
%
%
% __Output Arguments__
%
% * `Ans` [ ... ] - Answer to the query.
%
%
% __Valid Queries__
%
% * `'End='` Returns [ numeric ] the date of the last observation.
%
% * `'Freq='` Returns [ numeric ] the frequency (periodicity) of the time
% series.
%
% * `'NaNEnd='` Returns [ numeric ] the last date at which observations are
% available in all columns; for scalar tseries, this query always returns
% the same as `'end'`.
%
% * `'NaNRange='` Returns [ numeric ] the date range from `'nanstart'` to
% `'nanend'`; for scalar time series, this query always returns the same as
% `'range'`.
%
% * `'NaNStart='` Returns [ numeric ] the first date at which observations are
% available in all columns; for scalar tseries, this query always returns
% the same as `'start'`.
%
% * `'Range='` Returns [ numeric ] the date range from the first observation to the
% last observation.
%
% * `'Start='` Returns [ numeric ] the date of the first observation.
%
%
% __Description__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

P = inputParser( );
P.addRequired('Query', @iscellstr);
P.parse(varargin);

%--------------------------------------------------------------------------

[varargout{1:nargout}] = get@shared.GetterSetter(this, varargin{:});

end
