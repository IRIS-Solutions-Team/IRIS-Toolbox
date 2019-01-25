function X = arf(X, A, Z, Range, varargin)
% arf  Run autoregressive function on time series.
%
%
% __Syntax__
%
%     X = arf(X, A, Z, Range, ...)
%
%
% __Input arguments__
%
% * `X` [ tseries ] - Input data from which initial condition will be
% taken.
%
% * `A` [ numeric ] - Vector of coefficients of the autoregressive
% polynomial.
%
% * `Z` [ numeric | tseries ] - Exogenous input series or constant in the
% autoregressive process.
%
% * `Range` [ numeric | `@all` ] - Date range on which the new time series
% observations will be computed; `Range` does not include pre-sample
% initial condition. `@all` means the entire possible range will be used
% (taking into account the length of pre-sample initial condition needed).
%
%
% __Output arguments__
%
% * `X` [ tseries ] - Output data with new observations created by running
% an autoregressive process described by `A` and `Z`.
%
%
% __Description__
%
% The autoregressive process has one of the following forms:
%
%     A1*x + A2*x(-1) + ... + An*x(-n) = z, 
%
% or
%
%     A1*x + A2*x(+1) + ... + An*x(+n) = z, 
%
% depending on whether the range is increasing (running forward in time), 
% or decreasing (running backward in time). The coefficients `A1`, ...`An`
% are gathered in the input vector `A`, 
%
%     A = [A1, A2, ..., An].
%
%
% __Example__
%
% The following two lines create an autoregressive process constructed from
% normally distributed residuals, 
%
% $$ x_t = \rho x_{t-1} + \epsilon_t $$
%
%     rho = 0.8;
%     X = Series(1:20, @randn);
%     X = arf(X, [1, -rho], X, 2:20);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

if nargin < 4
    Range = Inf;
end

% Parse input arguments.
pp = inputParser( );
pp.addRequired('X', @(x) isa(x, 'tseries'));
pp.addRequired('A', @isnumeric);
pp.addRequired('Z', @(x) isnumericscalar(x) || isa(x, 'tseries'));
pp.addRequired('Range', @(x) isnumeric(x) || isequal(x, @all));
pp.parse(X, A, Z, Range);

%--------------------------------------------------------------------------

A = A(:).';
order = length(A) - 1;

% Work out range (includes pre/post-sample initial condition).
xfirst = X.start;
xlast = X.start + size(X.data, 1) - 1;
if isequal(Range, Inf)
    Range = xfirst : xlast;
end
if Range(1) <= Range(end)
    time = 'forward';
    Range = Range(1)-order : Range(end);
else
    time = 'backward';
    Range = Range(end) : Range(1)+order;
end

% Get endogenous data.
xData = rangedata(X, Range);
xSize = size(xData);
xData = xData(:, :);

% Do noting if effective range is empty.
nPer = length(Range);
if nPer<=order
    return
end

% Get exogenous (z) data.
if isa(Z, 'TimeSubscriptable')
    zData = getData(Z, Range);
    zData = zData(:, :);
    % expand zData in 2nd dimension if needed
else
    if isempty(Z)
        Z = 0;
    end
    zData = repmat(zData, nPer, 1);
end
if size(zData, 2)==1 && size(xData, 2)>1
    zData = repmat(zData, 1, size(xData, 2));
end

% Normalise polynomial vector.
if A(1) ~= 1
    zData = zData / A(1);
    A = A / A(1);
end

% Run AR.
if strcmp(time, 'forward')
    shifts = -1 : -1 : -order;
    timeVec = 1+order : nPer;
else
    shifts = 1 : order;
    timeVec = nPer-order : -1 : 1;
end

for i = 1 : size(xData, 2)
    for t = timeVec
        xData(t, i) = -A(2:end)*xData(t+shifts, i) + zData(t, i);
    end
end

% Update output series.
X = subsasgn(X, Range, reshape(xData, [size(xData, 1), xSize(2:end)]));

end%

