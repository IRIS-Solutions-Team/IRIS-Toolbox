function [C, R] = acf(this, varargin)
% acf  Sample autocovariance and autocorrelation functions
%
% __Syntax__
%
%     [C, R] = acf(x)
%     [C, R] = acf(x, dates, ...)
%
%
% __Input Arguments__
%
% * `x` [ NumericTimeSubscriptable ] - Input time series.
%
% * `dates` [ numeric | Inf ] - Dates or date range from which the input
% tseries data will be used.
%
%
% __Output Arguments__
%
% * `C` [ numeric ] - Auto-/cross-covariance matrices.
%
% * `R` [ numeric ] - Auto-/cross-correlation matrices.
%
%
% __Options__
%
% * `Demean=true` [ `true` | `false` ] - Estimate and remove sample mean
% from the data before computing the ACF.
%
% * `Order=0` [ numeric ] - The order up to which the ACF will be computed.
%
% * `SmallSample=true` [ `true` | `false` ] - Adjust the degrees of freedom
% for small samples by subtracting `1` from the number of periods.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%#ok<*VUNUS>
%#ok<*CTCH>

persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable.acf');
    parser.addRequired('InputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    parser.addOptional('Dates', Inf, @DateWrapper.validateDateInput);
    parser.addParameter('Demean', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Order', 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    parser.addParameter('SmallSample', true, @(x) isequal(x, true) || isequal(x, false));
end
parser.parse(this, varargin{:});
dates = parser.Results.Dates;
opt = parser.Options;

%--------------------------------------------------------------------------

data = getData(this, dates);
if ndims(data)>3
    data = data(:, :, :);
end

% Remove leading and trailing NaN rows
if isequal(data, Inf)
    inxToKeep = all(~isnan(data(:, :)), 2);
    data = data(inxToKeep, :, :);
end

C = covfun.acovfsmp(data, opt);
if nargout>1
    R = covfun.cov2corr(C);
end

end%

