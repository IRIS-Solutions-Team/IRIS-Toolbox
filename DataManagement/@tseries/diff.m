function x = diff(x, shifts)
% diff  First difference
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     X = diff(X, ~Shift)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series.
%
% * `~Shift` [ numeric ] - Number of periods over which the first difference
% will be computed; `Y = X - X{Shift}`; `Shift` is a negative number
% for the usual backward differencing; if omitted, `Shift=1`.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - First difference of the input time series.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2017 IRIS Solutions Team

% diff, df, pct, apct

if nargin<2
    shifts = -1;
end

if isempty(shifts)
    x = apply.empty(x, 2);
    return
end

%--------------------------------------------------------------------------

x = unop(@apply.diff, x, 0, shifts);

end
