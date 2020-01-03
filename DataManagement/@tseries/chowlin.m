function [Y2, B, Rho, U1, U2] = chowlin(Y1, X2, Range, varargin)
% chowlin  Chow-Lin distribution of low-frequency observations over higher-frequency periods
%
% __Syntax__
%
%     [Y2, B, RHO, U1, U2] = chowlin(Y1, X2)
%     [Y2, B, RHO, U1, U2] = chowlin(Y1, X2, Range, ...)
%
%
% __Input Arguments__
%
% * `Y1` [ tseries ] - Low-frequency input time series that will be
% distributed over higher-frequency observations.
%
% * `X2` [ tseries ] - Time series with regressors used to distribute the
% input data.
%
% * `Range` [ numeric ] - Low-frequency date range on which the
% distribution will be computed.
%
%
% __Output Arguments__
%
% * `Y2` [ tseries ] - Output data distributed with higher frequency.
%
% * `B` [ numeric ] - Vector of regression coefficients.
%
% * `RHO` [ numeric ] - Actually used autocorrelation coefficient in the
% residuals.
%
% * `U1` [ tseries ] - Low-frequency regression residuals.
%
% * `U2` [ tseries ] - Higher-frequency regression residuals.
%
%
% __Options__
%
% * `Constant=true` [ `true` | `false` ] - Include a constant term in the
% regression.
%
% * `Log=false` [ `true` | `false` ] - Logarithmise the data before
% distribution, de-logarithmise afterwards.
%
% * `NGrid=200` [ numeric ] - Number of grid search points for finding
% autocorrelation coefficient for higher-frequency residuals.
%
% * `Rho='Estimate'` [ `'Estimate'` | `'Positive'` | `'Negative'` | numeric ]
% - How to determine the autocorrelation coefficient for higher-frequency
% residuals.
%
% * `TimeTrend=false` [ `true` | `false` ] - Include a time trend in the
% regression.
%
%
% __Description__
%
% * Chow, G.C., and A.Lin (1971). Best Linear Unbiased Interpolation, 
% Distribution and Extrapolation of Time Series by Related Times Series.
% Review of Economics and Statistics, 53, pp. 372-75.
%
% * Robertson, J.C., and E.W.Tallman (1999). Vector Autoregressions:
% Forecasting and Reality. FRB Atlanta Economic Review, 1st Quarter 1999, 
% pp.4-17.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

try
    Range; %#ok<VUNUS>
catch
    Range = Inf;
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('TimeSubscriptable/chowlin');
    parser.addRequired('Y1', @(x) isa(x, 'TimeSubscriptable'));
    parser.addRequired('X2', @(x) isa(x, 'TimeSubscriptable'));
    parser.addRequired('Range', @DateWrapper.validateDateInput);
    parser.addParameter('Constant', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Log', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('NGrid', 200, @(x) isnumeric(x) && scalar(x) && x>=1);
    parser.addParameter('Rho', 'Estimate', @(x) any(strcmpi(x, {'Auto', 'Estimate', 'Negative', 'Positive'})) || (isnumeric(x) && isscalar(x) && x>-1 && x<1));
    parser.addParameter('TimeTrend', false, @(x) isequal(x, true) || isequal(x, false));
end
parser.parse(Y1, X2, Range, varargin{:});
opt = parser.Options;

if ischar(Range)
    Range = textinp2dat(Range);
end

%--------------------------------------------------------------------------

f1 = get(Y1, 'freq');
if isnumericscalar(X2)
    f2 = X2;
    X2 = [ ];
else
    f2 = get(X2, 'freq');
end

if f2<=f1
    THIS_ERROR = { 'TimeSubscriptable:ChowLinInconsistentFrequency'
                   'RHS variables must have higher frequency than the LHS variable' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

% Number of high-frequency periods within a low-frequency period. Must be
% an integer.
g = f2 / f1;
if g~=round(g)
    THIS_ERROR = { 'TimeSubscriptable:ChowLinInconsistentFrequency'
                   'High frequency must be a multiple of low frequency' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

% Get low-frequency LHS observations.
[y1Data, range1] = rangedata(Y1, Range);
if opt.Log
    y1Data = log(y1Data);
end
nPer1 = length(range1);

% Set up High-frequency range.
start2 = numeric.convert(range1(1), f2, 'ConversionMonth', 'first');
end2 = numeric.convert(range1(end), f2, 'ConversionMonth', 'last');
range2 = start2 : end2;
nPer2 = length(range2);

% Aggregation matrix.
c = ones(1, g) / g;
C = kron(eye(nPer1), c);

% Convert high-frequency explanatory variables to low frequency by
% averaging.
if ~isempty(X2)
    x2Data = rangedata(X2, range2);
    if opt.Log
        x2Data = log(x2Data);
    end
    nx = size(x2Data, 2);
    x1data = nan(nPer1, nx);
    for i = 1 : nx
        tmp = reshape(x2Data(:, i), [g, nPer1]);
        tmp = c*tmp;
        x1data(:, i) = tmp(:);
    end
end

% Set-up RHS matrix.
M1 = [ ];
M2 = [ ];
if opt.Constant
    M1 = [M1, ones(nPer1, 1)];
    M2 = ones(nPer2, 1);
end
if opt.TimeTrend
    t2 = (1 : nPer2)';
    t1 = C*t2;
    M1 = [M1, t1];
    M2 = [M2, t2];
end
if ~isempty(X2)
    M1 = [M1, x1data];
    M2 = [M2, x2Data];
end

if isempty(M1)
    THIS_ERROR = { 'TimeSubscriptable:ChowLinLHSRegressorMissing'
                   'No left-hand-side regressor specified' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

% Run regression and compute autocorrelation of residuals.
sample1 = all(~isnan([M1, y1Data]), 2);
B = M1(sample1, :) \ y1Data(sample1);
tmp = y1Data(sample1) - M1(sample1, :)*B;
rho1 = tmp(1:end-1) \ tmp(2:end);
u1Data = nan(size(y1Data));
u1Data(sample1) = tmp;

% Project high-frequency explanatory variables.
sample2 = all(~isnan(M2), 2);
y2Data = M2*B;

% Correct for residuals.
if any(strcmpi(opt.Rho, {'auto', 'estimate', 'positive', 'negative'}))
    % Determine high-frequency autocorrelation consistent with estimated
    % low-frequency autocorrelation.
    rho2 = xxAutoCorr(rho1, f1, f2, opt.NGrid);
    % Set rho2 to zero if it's estimate is negative and the user restricted
    % the estimated value to be positive or vice versa.
    if (strcmpi(opt.Rho, 'positive') && rho2 < 0) ...
            || (strcmpi(opt.Rho, 'negative') && rho2 > 0)
        rho2 = 0;
    end
else
    rho2 = opt.Rho;
end
tmp = u1Data;
tmp(~sample1) = 0;
if rho2 ~= 0
    P2 = toeplitz(rho2.^(0 : nPer2-1));
    u2Data = P2*C'*((C*P2*C')\tmp);
else
    u2Data = C'*((C*C')\tmp);
end
u2Data(~sample2) = NaN;
y2Data = y2Data + u2Data;

% Output data.
if opt.Log
    u1Data = exp(u1Data);
    y2Data = exp(y2Data);
    u2Data = exp(u2Data);
end
U1 = replace(Y1, u1Data, range1(1));
Y2 = replace(Y1, y2Data, range2(1));
U2 = replace(Y1, u2Data, range2(1));
Rho = [rho1, rho2];

end%


function Rho2 = xxAutoCorr(Rho1, F1, F2, NGrid)
% xxAutoCorr  Use a simple grid search to find high-frequency
% autocorrelation coeeficient corresponding to the estimated low-frequency
% one.
g = F2 / F1;
C = blkdiag(ones(1, g), ones(1, g))/g;
rho2s = linspace(-1, 1, NGrid+2);
rho2s = rho2s(2:end-1);
rho1s = nan(size(rho2s));
for i = 1 : numel(rho2s)
    rho1s(i) = doTry(rho2s(i));
end
[~, ix] = min(abs(rho1s - Rho1));
Rho2 = rho2s(ix);
    function rho1 = doTry(rho2)
        P2 = toeplitz(rho2.^(0:2*g-1));
        P1 = C*P2*C';
        rho1 = P1(2, 1) / P1(1, 1);
    end%
end%

