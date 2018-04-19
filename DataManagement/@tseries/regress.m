function [b, stdB, e, stdE, fit, dates, covB] = regress(Y, X, varargin)
% regress  Ordinary or weighted least-square regression.
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
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.regress');
    inputParser.addRequired('Y', @(x) isa(x, 'tseries'));
    inputParser.addRequired('X', @(x) isa(x, 'tseries'));
    inputParser.addOptional('Dates', Inf, @DateWrapper.validateDateInput);
    inputParser.addParameter({'Intercept', 'Constant'}, false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter({'Weights', 'Weighting'}, [ ] , @(x) isempty(x) || isa(x, 'tseries'));
end
inputParser.parse(Y, X, varargin{:});
dates = inputParser.Results.Dates;
opt = inputParser.Options;

%--------------------------------------------------------------------------

[dataY, dates] = getData(Y, dates);
dataX = getData(X, dates);
if opt.Intercept
    dataX(:, end+1) = 1;
end

if isempty(opt.Weights)
    indexRows = all(~isnan([dataX, dataY]), 2);
    [b, stdB, eVar, covB] = lscov(dataX(indexRows, :), dataY(indexRows, :));
else
    dataWeights = getData(opt.Weights, dates);
    indexRows = all(~isnan([dataX, dataY, dataWeights]), 2);
    [b, stdB, eVar, covB] = lscov(dataX(indexRows, :), dataY(indexRows, :), dataWeights(indexRows, :));
end
stdE = sqrt(eVar);

if nargout>2
    startDate = getFirst(dates);
    dataFit = dataX*b;
    dataE = dataY - dataFit;
    e = fill(Y, dataE, startDate, '');
    if nargout>4
        fit = fill(Y, dataFit, startDate, '');
    end
end

end
