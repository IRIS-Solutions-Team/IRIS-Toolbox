function [B, BStd, E, EStd, YFit, Range, BCov] = regress(Y, X, varargin)
% regress  Ordinary or weighted least-square regression.
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [B, BStd, E, EStd, YFit, Range, BCov] = regress(Y, X, ~Range, ...)
%
%
% __Input arguments__
%
% * `Y` [ tseries ] - Tseries object with independent (LHS) variables.
%
% * `X` [ tseries] - Tseries object with regressors (RHS) variables.
%
% * `~Range` [ numeric ] - Date range on which the regression will be run;
% if omitted, the entire range available will be used.
%
%
% __Output arguments__
%
% * `B` [ numeric ] - Vector of estimated regression coefficients.
%
% * `BStd` [ numeric ] - Vector of std errors of the estimates.
%
% * `E` [ tseries ] - Tseries object with the regression residuals.
%
% * `EStd` [ numeric ] - Estimate of the std deviation of the regression
% residuals.
%
% * `YFit` [ tseries ] - Tseries object with fitted LHS variables.
%
% * `Range` [ numeric ] - The actually used date range.
%
% * `bBCov` [ numeric ] - Covariance matrix of the coefficient estimates.
%
%
% __Options__
%
% * `'constant='` [ `true` | *`false`* ] - Include a constant vector in the
% regression; if `true` the constant will be placed last in the matrix of
% regressors.
%
% * `'weighting='` [ tseries | *empty* ] - Tseries object with weights on
% observations in individual periods.
%
%
% __Description__
%
% This function calls the built-in `lscov` function.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries/regress');
    INPUT_PARSER.addRequired('Y', @(x) isa(x, 'tseries'));
    INPUT_PARSER.addRequired('X', @(x) isa(x, 'tseries'));
    INPUT_PARSER.addRequired('Range', @DateWrapper.validateDateInput);
end

if ~isempty(varargin) && isnumeric(varargin{1})
    Range = varargin{1};
    varargin(1) = [ ];
else
    Range = Inf;
end

% Parse input arguments.
INPUT_PARSER.parse(Y, X, Range);

% Parse options.
opt = passvalopt('tseries.regress', varargin{:});

%--------------------------------------------------------------------------

if length(Range)==1 && isinf(Range)
    Range = get([X, Y], 'minRange');
else
    Range = Range(1) : Range(end);
end

xData = rangedata(X, Range);
yData = rangedata(Y, Range);
if opt.constant
    xData(:, end+1) = 1;
end

indexOfRows = all(~isnan([xData, yData]), 2);

if isempty(opt.weighting)
    [B, BStd, eVar, BCov] = lscov(xData(indexOfRows, :), yData(indexOfRows, :));
else
    w = rangedata(opt.weighting, Range);
    [B, BStd, eVar, BCov] = lscov(xData(indexOfRows, :), yData(indexOfRows, :), w(indexOfRows, :));
end
EStd = sqrt(eVar);

if nargout>2
    E = replace(Y, yData - xData*B, Range(1));
end

if nargout>4
    YFit = replace(Y, xData*B, Range(1));
end

end
