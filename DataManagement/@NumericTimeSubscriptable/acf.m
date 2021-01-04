function [C, R] = acf(this, varargin)
% acf  Sample autocovariance and autocorrelation functions
%{
% __Syntax__
%
%     [C, R] = acf(x)
%     [C, R] = acf(x, dates, ...)
%
%
% ## Input Arguments ##
%
%
% __`x`__ [ NumericTimeSubscriptable ]
% >
% Input time series.
%
%
% __`dates`__ [ numeric | Inf ]
% >
% Dates or date range from which the input
% tseries data will be used.
%
%
% ## Output Arguments ##
%
%
% __`C`__ [ numeric ]
% >
% Auto-/cross-covariance matrices.
%
%
% __`R`__ [ numeric ]
% >
% Auto-/cross-correlation matrices.
%
%
% ## Options ##
%
%
% __`Demean=true`__ [ `true` | `false` ]
% >
% Estimate and remove sample mean from the data before computing the ACF.
%
%
% __`Order=0`__ [ numeric ]
% >
% The order up to which the ACF will be computed.
%
%
% __`SmallSample=true`__ [ `true` | `false` ]
% >
% Adjust the degrees of freedom for small samples by subtracting `1` from
% the number of periods.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%#ok<*VUNUS>
%#ok<*CTCH>

persistent pp
if isempty(pp)
    pp = extend.InputParser('NumericTimeSubscriptable.acf');
    addRequired(pp, 'InputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    addOptional(pp, 'Dates', Inf, @Dater.validateDateInput);

    addParameter(pp, 'Demean', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Order', 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    addParameter(pp, 'SmallSample', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'RemoveNaN', true, @validate.logicalScalar);
end
pp.parse(this, varargin{:});
dates = pp.Results.Dates;
opt = pp.Options;

%--------------------------------------------------------------------------

data = getData(this, dates);
if ndims(data)>3
    data = data(:, :, :);
end

% Remove leading and trailing NaN rows
if opt.RemoveNaN
    inxToRemove = any(isnan(data(:, :)), 2);
    data = data(~inxToRemove, :, :);
end

C = covfun.acovfsmp(data, opt);
if nargout>1
    R = covfun.cov2corr(C);
end

end%

