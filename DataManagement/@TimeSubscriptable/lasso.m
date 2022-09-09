function [B, BStd, residuals, EStd, fitted, range, BCov] = lasso(Y, X, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('TimeSubscriptable.lasso');
    pp.addRequired('Y', @(x) isa(x, 'TimeSubscriptable') && isnumeric(x.Data) && ismatrix(x.Data));
    pp.addRequired('X', @(x) isa(x, 'TimeSubscriptable') && isnumeric(x.Data) && ismatrix(x.Data));
    pp.addOptional('range', Inf, @validate.date);

    pp.addParameter({'Intercept', 'Constant', 'Const'}, false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter( ...
        'Weighting', [ ], ...
        @(x) isempty(x) ...
        || (isa(x, 'TimeSubscriptable') && isnumeric(x.Data) && ismatrix(x.Data)) ...
        || (isnumeric(x) && isscalar(x) && x>0 && x<1) ...
    );
end
parse(pp, Y, X, varargin{:});
range = double(pp.Results.range);
opt = pp.Options;

%--------------------------------------------------------------------------

isWeightingSeries = ~isempty(opt.Weighting) && isa(opt.Weighting, 'TimeSubscriptable');
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
