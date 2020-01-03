function [b, stdB, e, stdE, fit, dates, covB] = regress(Y, X, varargin)
% regress  Ordinary or weighted least-square regression
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [B, StdB, E, StdE, YFit, Dates, CovB] = regress(Y, X, ~Dates, ...)
%
%
% __Input arguments__
%
% * `Y` [ tseries ] - Tseries object with independent (LHS) variables.
%
% * `X` [ tseries] - Tseries object with regressors (RHS) variables.
%
% * `~Dates=Inf` [ DateWrapper ] - Dates on which the regression will be
% run; if omitted, the entire range available will be used.
%
%
% __Output arguments__
%
% * `B` [ numeric ] - Vector of estimated regression coefficients.
%
% * `StdB` [ numeric ] - Vector of std errors of the estimates.
%
% * `E` [ tseries ] - Tseries object with the regression residuals.
%
% * `StdE` [ numeric ] - Estimate of the std deviation of the regression
% residuals.
%
% * `YFit` [ tseries ] - Tseries object with fitted LHS variables.
%
% * `Dates` [ numeric ] - The dates of observations actually used in the
% regression.
%
% * `CovB` [ numeric ] - Covariance matrix of the coefficient estimates.
%
%
% __Options__
%
% * `Intercept=false` [ `true` | `false` ] - Include an intercept in the
% regression; if `true` the intercept will be placed last in the matrix of
% predictors.
%
% * `Weights=[ ]` [ tseries | empty ] - Time series  with weights on
% observations in individual periods, or an empty array for equal weights.
%
%
% __Description__
%
% This function calls the built-in `lscov` function.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('tseries.regress');
    parser.addRequired('Y', @(x) isa(x, 'tseries'));
    parser.addRequired('X', @(x) isa(x, 'tseries'));
    parser.addOptional('Dates', Inf, @DateWrapper.validateDateInput);
    parser.addParameter({'Intercept', 'Constant'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'Weights', 'Weighting'}, [ ] , @(x) isempty(x) || isa(x, 'tseries'));
end
parser.parse(Y, X, varargin{:});
dates = parser.Results.Dates;
opt = parser.Options;

%--------------------------------------------------------------------------

dates = double(dates);
checkFrequency(Y, dates);
[dataY, dates] = getData(Y, dates);
checkFrequency(X, dates);
dataX = getData(X, dates);
if opt.Intercept
    dataX(:, end+1) = 1;
end

if isempty(opt.Weights)
    inxOfRows = all(~isnan([dataX, dataY]), 2);
    [b, stdB, eVar, covB] = lscov(dataX(inxOfRows, :), dataY(inxOfRows, :));
else
    checkFrequency(opt.Weights, dates);
    dataWeights = getData(opt.Weights, dates);
    inxOfRows = all(~isnan([dataX, dataY, dataWeights]), 2);
    [b, stdB, eVar, covB] = lscov(dataX(inxOfRows, :), dataY(inxOfRows, :), dataWeights(inxOfRows, :));
end
stdE = sqrt(eVar);

if nargout>2
    startDate = getFirst(dates);
    dataFit = dataX*b;
    dataE = dataY - dataFit;
    e = Y.empty(Y);
    e = setData(e, dates, dataE);
    e = resetComment(e);
    if nargout>4
        fit = Y.empty(Y);
        fit = setData(fit, dates, dataFit);
        fit = resetComment(fit);
    end
end

end%

