% regress  Ordinary or weighted least-square regression
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [B, StdB, E, StdE, YFit, Dates, CovB] = regress(lhs, rhs, ~Dates, ...)
%
%
% __Input arguments__
%
% * `lhs` [ tseries ] - Time Series with independent (LHS) variables.
%
% * `rhs` [ tseries] - Tseries object with regressors (RHS) variables.
%
% * `~Dates=Inf` [ Dater ] - Dates on which the regression will be
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

function [b, stdB, e, stdE, fit, dates, covB] = regress(lhs, rhs, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('@Series/regress');
    pp.addRequired('lhs', @(x) isa(x, 'NumericTimeSubscriptable'));
    pp.addRequired('rhs', @(x) isa(x, 'NumericTimeSubscriptable'));
    pp.addOptional('Dates', Inf, @Dater.validateDateInput);
    pp.addParameter({'Intercept', 'Constant'}, false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter({'Weights', 'Weighting'}, [ ] , @(x) isempty(x) || isa(x, 'tseries'));
end
parse(pp, lhs, rhs, varargin{:});
dates = double(pp.Results.Dates);
opt = pp.Options;

%--------------------------------------------------------------------------

checkFrequency(lhs, dates);
[dataY, dates] = getData(lhs, dates);
dates = double(dates);
checkFrequency(rhs, dates);
dataX = getData(rhs, dates);
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
    dataFit = dataX*b;
    dataE = dataY - dataFit;
    e = lhs.empty(lhs);
    e = setData(e, dates, dataE);
    e = resetComment(e);
    if nargout>4
        fit = lhs.empty(lhs);
        fit = setData(fit, dates, dataFit);
        fit = resetComment(fit);
    end
end

end%

