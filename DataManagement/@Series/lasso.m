% lasso  Least absolute shrinkage and selection operator
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [B, BStd, Residuals, EStd, Fitted, Range, BCov] = lasso(Y, X, ~Range, ...)
%
%
% __Input arguments__
%
% * `Y` [ Series ] - Time series of left-hand-side (dependent)
% observations.
%
% * `X` [ Series ] - Time series of right-hand-side
% (independent) observations. 
%
% * `~Range` [ numeric ] - Date range on which the lasso will be run;
% if omitted, the entire range available will be used.
%
%
% __Output arguments__
%
% * `B` [ numeric ] - Vector of estimated lasso coefficients.
%
% * `BStd` [ numeric ] - Vector of std errors of the estimates.
%
% * `Residuals` [ Series ] - Time series with the lasso residuals.
%
% * `EStd` [ numeric ] - Estimate of the std deviation of the lasso
% residuals.
%
% * `Fitted` [ Series ] - Time series with fitted LHS
% observations.
%
% * `Range` [ numeric ] - The actually used date range.
%
% * `bBCov` [ numeric ] - Covariance matrix of the coefficient estimates.
%
%
% __Options__
%
% * `Intercept=false` [ `true` | `false` ] - Include an intercept in the
% lasso; if `true` the constant will be placed last in the matrix of
% lassoors.
%
% * `Weighting=[ ]` [ Series | numeric | empty ] - Time series with weights on
% observations in individual periods, or a discount factor for weighting
% the observations from the most recent to the most distant.
%
%
% __Description__
%
% This function calls the built-in `lscov` function.
%
%
% __Example__
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [B, BStd, residuals, EStd, fitted, range, BCov] = lasso(Y, X, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('Series.lasso');
    pp.addRequired('Y', @(x) isa(x, 'Series') && isnumeric(x.Data) && ismatrix(x.Data));
    pp.addRequired('X', @(x) isa(x, 'Series') && isnumeric(x.Data) && ismatrix(x.Data));
    pp.addOptional('range', Inf, @validate.date);

    pp.addParameter({'Intercept', 'Constant', 'Const'}, false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter( ...
        'Weighting', [ ], ...
        @(x) isempty(x) ...
        || (isa(x, 'Series') && isnumeric(x.Data) && ismatrix(x.Data)) ...
        || (isnumeric(x) && isscalar(x) && x>0 && x<1) ...
    );
end
parse(pp, Y, X, varargin{:});
range = double(pp.Results.range);
opt = pp.Options;

%--------------------------------------------------------------------------

isWeightingSeries = ~isempty(opt.Weighting) && isa(opt.Weighting, 'Series');
isWeightingScalar = ~isempty(opt.Weighting) && isnumeric(opt.Weighting);
numLhs = size(Y.Data, 2);
numRhs = size(X.Data, 2);

if isWeightingSeries
    allSeries = [Y, X, opt.Weighting];
else
    allSeries = [Y, X];
end
[allData, range] = getData(allSeries, range);
yData = allData(:, 1:numLhs);
xData = allData(:, numLhs+(1:numRhs));
wData = allData(:, numLhs+numRhs+1:end);
if opt.Intercept
    xData(:, end+1) = 1;
end

indexRows = all(~isnan(allData), 2);
numPeriods = nnz(indexRows);
if isWeightingScalar
    beta = opt.Weighting;
    wData = nan(size(yData, 1), 1);
    wData(indexRows) = beta.^(0:numPeriods-1).';
end

if isempty(wData)
    [B, BStd, eVar, BCov] = lscov(xData(indexRows, :), yData(indexRows, :));
else
    [B, BStd, eVar, BCov] = lscov(xData(indexRows, :), yData(indexRows, :), wData(indexRows, :));
end
EStd = sqrt(eVar);

if nargout>2
    startDate = range(1);
    fittedData = xData*B;
    residualsData = yData - fittedData;
    residuals = fill(Y, residualsData, startDate);
    if nargout>4
        fitted = fill(Y, fittedData, startDate);
    end
end

end%

