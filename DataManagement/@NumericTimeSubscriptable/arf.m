function X = arf(X, A, Z, range, varargin)
% arf  Create autoregressive time series from input data
%
% __Syntax__
%
%     X = arf(X, A, Z, range, ...)
%
%
% __Input arguments__
%
% * `X` [ NumericTimeSubscriptable ] - Input data from which initial
% condition will be taken.
%
% * `A` [ numeric ] - Vector of coefficients of the autoregressive
% polynomial.
%
% * `Z` [ numeric | NumericTimeSubscriptable ] - Exogenous input series or
% constant in the autoregressive process.
%
% * `range` [ numeric | `@all` ] - Date range on which the new time series
% observations will be computed; `range` does not include pre-sample
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

if nargin < 4
    range = Inf;
end

% Parse input arguments
persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable.arf');
    parser.addRequired('X', @(x) isa(x, 'NumericTimeSubscriptable'));
    parser.addRequired('A', @isnumeric);
    parser.addRequired('Z', @(x) Valid.numericScalar(x) || isa(x, 'NumericTimeSubscriptable'));
    parser.addRequired('Range', @(x) isnumeric(x) || isequal(x, @all));
end%
parser.parse(X, A, Z, range);
range = double(range);

%--------------------------------------------------------------------------

A = A(:).';
order = length(A) - 1;

% Work out range (includes pre/post-sample initial condition)
startOfX = X.StartAsNumeric;
endOfX = X.EndAsNumeric;
if isequal(range, Inf)
    range = startOfX : endOfX;
end
if range(1)<=range(end)
    time = 'forward';
    extendedRange = range(1)-order : range(end);
else
    time = 'backward';
    extendedRange = range(end) : range(1)+order;
end

% Get endogenous data
xData = getData(X, extendedRange);
sizeOfX = size(xData);
ndimsOfX = numel(sizeOfX);
xData = xData(:, :);
numOfPeriods = length(extendedRange);

% Do noting if the effective range is empty
if numOfPeriods<=order
    return
end

% Get exogenous (z) data
if isa(Z, 'TimeSubscriptable')
    zData = getData(Z, extendedRange);
    zData = zData(:, :);
else
    zData = Z;
    if isempty(zData)
        zData = 0;
    end
    zData = repmat(zData, numOfPeriods, 1);
end

% Expand zData in 2nd dimension if needed
if size(zData, 2)==1 && size(xData, 2)>1
    zData = repmat(zData, 1, size(xData, 2));
end

% Normalise polynomial vector
if A(1)~=1
    zData = zData / A(1);
    A = A / A(1);
end

% Set up time vector
if strcmp(time, 'forward')
    shifts = -1 : -1 : -order;
    timeVec = 1+order : numOfPeriods;
else
    shifts = 1 : order;
    timeVec = numOfPeriods-order : -1 : 1;
end


% /////////////////////////////////////////////////////////////////////////
for t = timeVec
    xData(t, :) = -A(2:end)*xData(t+shifts, :) + zData(t, :);
end
% /////////////////////////////////////////////////////////////////////////


% Reshape output data back
if ndimsOfX>2
    xData = reshape(xData, [size(xData, 1), sizeOfX(2:end)]);
end

% Update output series
X = setData(X, extendedRange, xData);

end%

