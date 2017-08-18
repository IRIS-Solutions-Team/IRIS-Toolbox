function [CC, RR, lsyx] = acf(this, varargin)
% acf  Autocovariance and autocorrelation function for model variables.
%
% __Syntax__
%
%     [C, R, List] = acf(M, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Solved model object for which the autocorrelation
% function will be computed.
%
%
% __Output Arguments__
%
% * `C` [ namedmat | numeric ] - Covariance matrices.
%
% * `R` [ namedmat | numeric ] - Correlation matrices.
%
% * `List` [ cellstr ] - List of variables in rows and columns of `C` and
% `R`.
%
%
% __Options__
%
% * `'ApplyTo='` [ cellstr | char | *`@all`* ] - List of variables to which
% the `'Filter='` will be applied; `@all` means all variables.
%
% * `'Contributions='` [ `true` | *`false`* ] - If `true` the contributions
% of individual shocks to ACFs will be computed and stored in the 5th
% dimension of the `C` and `R` matrices.
%
% * `'Filter='` [ char  | *empty* ] - Linear filter that is applied to
% variables specified by 'applyto'.
%
% * `'NFreq='` [ numeric | *`256`* ] - Number of equally spaced frequencies
% over which the filter in the option `'Filter='` is numerically
% integrated.
%
% * `'Order='` [ numeric | *`0`* ] - Order up to which ACF will be
% computed.
%
% * `'MatrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrices `C` and
% `R` as either [`namedmat`](NamedMat) objects (matrices with
% named rows and columns) or plain numeric arrays.
%
% * `'Select='` [ *`@all`* | char | cellstr ] - Return ACF for selected
% variables only; `@all` means all variables.
%
%
% __Description__
%
% `C` and `R` are both n-by-n-by-(p+1)-by-v matrices, where n is the
% number of measurement and transition variables (including auxiliary lags
% and leads in the state space vector), p is the order up to which the ACF
% is computed (controlled by the option `'Order='`), and v is the number
% of parameter variants in the input model object, `M`.
% 
% If `'Contributions='` is `true`, the size of the two matrices is
% n-by-n-by-(p+1)-by-k-by-v, where k is the number of all shocks
% (measurement and transition) in the model.
%
%
% _ACF with Linear Filters_
%
% You can use the option `'Filter='` to get the ACF for variables as though
% they were filtered through a linear filter. You can specify the filter in
% both the time domain (such as first-difference filter, or
% Hodrick-Prescott) and the frequncy domain (such as a band of certain
% frequncies or periodicities). The filter is a text string in which you
% can use the following references:
%
% * `'L'` for the lag operator, which will be replaced with
% `'exp(-1i*freq)'`;
% * `'per'` for the periodicity;
% * `'freq'` for the frequency.
% 
%
% __Example__
%
% A first-difference filter (i.e. computes the ACF for the first
% differences of the respective variables):
%
%     [C, R] = acf(m, 'Filter=', '1-L')
%
%
% __Example__
%
% The cyclical component of the Hodrick-Prescott filter with the smoothing
% parameter, \(\lambda\), set to 1,600. The formula for the filter follows
% from the classical Wiener-Kolmogorov signal extraction theory, 
%
% $$w(L) = \frac{\lambda}{\lambda + \frac{1}{ | (1-L)(1-L) | ^2}}$$
%
%     [C, R] = acf(m, 'Filter=', '1600/(1600 + 1/abs((1-L)^2)^2)')
%
%
% __Example__
%
% A band-pass filter with user-specified lower and upper bands. The
% band-pass filters can be defined either in frequencies or periodicities;
% the latter is usually more convenient. The following is a filter which
% retains periodicities between 4 and 40 periods (this would be between 1
% and 10 years in a quarterly model), 
%
%     [C, R] = acf(m, 'Filter=', 'per>=4 & per<=40')
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

opt = passvalopt('model.acf', varargin{:});

isSelect = ~isequal(opt.select, @all);
isNamedMat = strcmpi(opt.MatrixFmt, 'namedmat');

%--------------------------------------------------------------------------

[ny, nxx, ~, ~, ne] = sizeOfSolution(this.Vector);
nAlt = length(this);

if opt.contributions
    nCont = ne;
else
    nCont = 1;
end
CC = nan(ny+nxx, ny+nxx, opt.order+1, nCont, nAlt);

% Pre-process filter options.
lsyx = printSolutionVector(this, 'yx');
[isFilter, filter, freq, applyTo] = freqdom.applyfilteropt(opt, [ ], lsyx);

% Call timedom package to compute autocovariance function.
isContributions = opt.contributions;
acfOrder = opt.order;
ixSolved = true(1, nAlt);
for iAlt = 1 : nAlt
    isExpand = false;
    [T, R, ~, Z, H, ~, U, Omg] = sspaceMatrices(this, iAlt, isExpand);

    % Continue immediately if solution is not available.
    ixSolved(iAlt) = all(~isnan(T(:)));
    if ~ixSolved(iAlt)
        continue
    end

    for iCont = 1 : nCont
        if isContributions
            inx = false(1, ne);
            inx(iCont) = true;
            if Omg(inx, inx) == 0
                CC(:, :, :, iCont, iAlt) = 0;
                continue
            end
        else
            inx = true(1, ne);
        end
        if isFilter
            nUnit = sum(this.Variant{iAlt}.Stability==TYPE(1));
            S = freqdom.xsf( ...
                T, R(:, inx), [ ], Z, H(:, inx), [ ], U, Omg(inx, inx), nUnit, ...
                freq, filter, applyTo);
            CC(:, :, :, iCont, iAlt) = freqdom.xsf2acf(S, freq, acfOrder);
        else
            CC(:, :, :, iCont, iAlt) = covfun.acovf( ...
                T, R(:, inx), [ ], Z, H(:, inx), [ ], U, Omg(inx, inx), ...
                this.Variant{iAlt}.Eigen, acfOrder);
        end
    end
end

% Report NaN solutions.
if any(~ixSolved)
    utils.warning('model:acf', ...
        'Solution(s) not available %s.', ...
        exception.Base.alt2str(~ixSolved) );
end

% Squeeze the covariance matrices if ~contributions.
if ~opt.contributions
    CC = reshape(CC, ny+nxx, ny+nxx, opt.order+1, nAlt);
end

% Fix negative variances (in the contemporaneous matrices).
CC(:, :, 1, :, :) = timedom.fixcov(CC(:, :, 1, :, :));

% Autocorrelation function.
if nargout > 1
    % Convert covariances to correlations.
    RR = covfun.cov2corr(CC);
end

% Select sub-matrices if requested.
if isSelect
    [CC, pos] = namedmat.myselect(CC, lsyx, lsyx, opt.select, opt.select);
    pos = pos{1};
    lsyx = lsyx(pos);
    try %#ok<TRYNC>
        RR = RR(pos, pos, :, :, :);
    end
end

if true % ##### MOSW
    % Convert double arrays to namedmat objects if requested.
    if isNamedMat
        CC = namedmat(CC, lsyx, lsyx);
        try %#ok<TRYNC>
            RR = namedmat(RR, lsyx, lsyx);
        end
    end
else
    % Do nothing.
end

end
