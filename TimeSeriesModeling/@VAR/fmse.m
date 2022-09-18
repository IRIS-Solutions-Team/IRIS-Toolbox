function [X, D, D1] = fmse(this, time, varargin)
% fmse  Forecast mean square error matrices.
%
% __Syntax__
%
%     [F, X] = fmse(V, NPer)
%     [F, X] = fmse(V, Range)
%
%
% __Input arguments__
%
% * `V` [ VAR ] - VAR object for which the forecast MSE matrices will be
% computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
%
% __Output arguments__
%
% * `F` [ namedmat | numeric ] - Forecast MSE matrices.
%
% * `X` [ dbase | tseries ] - Database or tseries with the std deviations
% of individual variables, i.e. the square roots of the corresponding
% diagonal elements of `M`.
%
%
% __Options__
%
% * `'MatrixFormat='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `F` as
% either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% rows and columns) or a plain numeric array.

%
% __Description__
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

TEMPLATE_SERIES = Series();


defaults = {
    'MatrixFormat', 'namedmat', @validate.matrixFormat
};

opt = passvalopt(defaults, varargin{:});


% Tell whether time is nper or range.
if length(time) == 1 && round(time) == time && time > 0
    range = 1 : time;
else
    range = time(1) : time(end);
end
nPer = length(range);

isNamedMat = strcmpi(opt.MatrixFormat, 'namedmat');

%--------------------------------------------------------------------------

ny = size(this.A, 1);
nAlt = size(this.A, 3);

% Orthonormalise residuals so that we do not have to multiply the VMA
% representation by Omega.
B = covfun.factorise(this.Omega);

% Get VMA representation.
X = timedom.var2vma(this.A, B, nPer);

% Compute FMSE matrices.
for iAlt = 1 : nAlt
    for t = 1 : nPer
        X(:, :, t, iAlt) = X(:, :, t, iAlt)*transpose(X(:, :, t, iAlt));
    end
end
X = cumsum(X, 3);

% Return std devs for individual series.
if nargout > 1
    x = nan(nPer, ny, nAlt);
    for i = 1 : ny
        x(:, i, :) = sqrt(permute(X(i, i, :, :), [3, 1, 4, 2]));
    end
    D = struct();
    for i = 1 : ny
        name = this.EndogenousNames(i);
        data = x(:, i, :);
        D.(name) = replace(TEMPLATE_SERIES, data(:, :), range(1));
    end
end

% Convert output matrix to namedmat object if requested
if isNamedMat
    X = namedmat(X, this.EndogenousNames, this.EndogenousNames);
end

end%

