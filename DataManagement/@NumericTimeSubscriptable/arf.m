function this = arf(this, A, Z, range, varargin)
% arf  Create autoregressive time series from input data
%
% ## Syntax ##
%
%     x = arf(x, A, Z, range, ...)
%
%
% ## Input arguments ##
%
% **`x`** [ NumericTimeSubscriptable ] - 
% Input data from which initial condition will be taken.
%
% **`A`** [ numeric ] - 
% Vector of coefficients of the autoregressive polynomial.
%
% **`Z`** [ numeric | NumericTimeSubscriptable ] - 
% Exogenous input series or constant in the autoregressive process.
%
% **`range`** [ numeric | `@all` ] - 
% Date range on which the new time series observations will be computed;
% `range` does not include pre-sample initial condition. `@all` means the
% entire possible range will be used (taking into account the length of
% pre-sample initial condition needed).
%
%
% ## Output Arguments ##
%
% **`x`** [ tseries ] - 
% Output data with new observations created by running an autoregressive
% process described by `A` and `Z`.
%
%
% ## Description ##
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
% ## Example ##
%
% The following two lines create an autoregressive process constructed from
% normally distributed residuals, 
%
% $$ x_t = \rho x_{t-1} + \epsilon_t $$
%
%     rho = 0.8;
%     x = Series(1:20, @randn);
%     x = arf(x, [1, -rho], x, 2:20);
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 IRIS Solutions Team

if nargin < 4
    range = Inf;
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable.arf');
    addRequired(parser, 'x', @(x) isa(x, 'NumericTimeSubscriptable'));
    addRequired(parser, 'A', @isnumeric);
    addRequired(parser, 'Z', @(x) validate.numericScalar(x) || isa(x, 'NumericTimeSubscriptable'));
    addRequired(parser, 'Range', @(x) isnumeric(x) || isequal(x, @all));
end%
parse(parser, this, A, Z, range);
range = double(range);

%--------------------------------------------------------------------------

A = A(:).';
order = length(A) - 1;

% Work out range (includes pre/post-sample initial condition)
if isequal(range, Inf)
    range = this.StartAsNumeric : this.EndAsNumeric;
end

if range(1)<=range(end)
    time = 'forward';
    extendedRange = range(1)-order : range(end);
else
    time = 'backward';
    extendedRange = range(end) : range(1)+order;
end
numOfExtendedPeriods = length(extendedRange);

% Get endogenous data
xData = getData(this, extendedRange);
sizeOfX = size(xData);
xData = xData(:, :);

% Get exogenous (z) data
if isa(Z, 'NumericTimeSubscriptable')
    zData = getData(Z, extendedRange);
else
    zData = Z;
    if isempty(zData)
        zData = 0;
    end
    zData = repmat(zData, numOfExtendedPeriods, 1);
end
sizeOfZ = size(zData);
zData = zData(:, :);

% Expand zData or xData in 2nd dimension if needed
if size(zData, 2)==1 && size(xData, 2)>1
    zData = repmat(zData, 1, size(xData, 2));
elseif size(zData, 2)>1 && size(xData, 2)==1
    xData = repmat(xData, 1, size(zData, 2));
    sizeOfX = sizeOfZ;
end

% Normalise polynomial vector
if A(1)~=1
    zData = zData / A(1);
    A = A / A(1);
end

% Set up time vector
if strcmp(time, 'forward')
    shifts = -1 : -1 : -order;
    timeVec = 1+order : numOfExtendedPeriods;
else
    shifts = 1 : order;
    timeVec = numOfExtendedPeriods-order : -1 : 1;
end


% /////////////////////////////////////////////////////////////////////////
for t = timeVec
    xData(t, :) = -A(2:end)*xData(t+shifts, :) + zData(t, :);
end
% /////////////////////////////////////////////////////////////////////////


% Reshape output data back
if numel(sizeOfX)>2
    xData = reshape(xData, [size(xData, 1), sizeOfX(2:end)]);
end

% Update output series
this = fill(this, xData, extendedRange(1));

end%

