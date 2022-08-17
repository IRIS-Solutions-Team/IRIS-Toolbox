function [Y2, B, Rho, U1, U2] = chowlin(Y1, X2, Range, varargin)

try
    Range; %#ok<VUNUS>
catch
    Range = Inf;
end

isnumericscalar = @(x) isnumeric(x) && isscalar(x);
persistent parser
if isempty(parser)
    parser = extend.InputParser('Series/chowlin');
    parser.addRequired('Y1', @(x) isa(x, 'Series'));
    parser.addRequired('X2', @(x) isa(x, 'Series'));
    parser.addRequired('Range', @validate.range);
    parser.addParameter('Constant', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Log', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('NGrid', 200, @(x) isnumeric(x) && scalar(x) && x>=1);
    parser.addParameter('Rho', 'Estimate', @(x) any(strcmpi(x, {'Auto', 'Estimate', 'Negative', 'Positive'})) || (isnumeric(x) && isscalar(x) && x>-1 && x<1));
    parser.addParameter('TimeTrend', false, @(x) isequal(x, true) || isequal(x, false));
end
parser.parse(Y1, X2, Range, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

f1 = get(Y1, 'freq');
if isnumericscalar(X2)
    f2 = X2;
    X2 = [ ];
else
    f2 = get(X2, 'freq');
end

if f2<=f1
    THIS_ERROR = { 'Series:ChowLinInconsistentFrequency'
                   'RHS variables must have higher frequency than the LHS variable' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

% Number of high-frequency periods within a low-frequency period. Must be
% an integer.
g = f2 / f1;
if g~=round(g)
    THIS_ERROR = { 'Series:ChowLinInconsistentFrequency'
                   'High frequency must be a multiple of low frequency' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

% Get low-frequency LHS observations.
[y1Data, startDate1, endDate1] = getDataFromTo(Y1, Range);
if opt.Log
    y1Data = log(y1Data);
end
nPer1 = dater.rangeLength(startDate1, endDate1);

% Set up High-frequency range.
startDate2 = dater.convert(startDate1, f2, 'ConversionMonth', 1);
endDate2 = dater.convert(endDate1, f2, 'ConversionMonth', 'last');
nPer2 = dater.rangeLength(startDate2, endDate2);

% Aggregation matrix.
c = ones(1, g) / g;
C = kron(eye(nPer1), c);

% Convert high-frequency explanatory variables to low frequency by
% averaging.
if ~isempty(X2)
    x2Data = getDataFromTo(X2, startDate2, endDate2);
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
    THIS_ERROR = { 'Series:ChowLinLHSRegressorMissing'
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
U1 = replace(Y1, u1Data, startDate1);
Y2 = replace(Y1, y2Data, startDate2);
U2 = replace(Y1, u2Data, startDate2);
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

