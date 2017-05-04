function [CC, RR, lsyx] = acf(this, varargin)
% acf  Autocovariance and autocorrelation function for model variables.
%
% Syntax
% =======
%
%     [C, R, List] = acf(M, ...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Solved model object for which the ACF will be computed.
%
%
% Output arguments
% =================
%
% * `C` [ namedmat | numeric ] - Auto/cross-covariance matrices.
%
% * `R` [ namedmat | numeric ] - Auto/cross-correlation matrices.
%
% * `List` [ cellstr ] - List of variables in rows and columns of `C` and
% `R`.
%
%
% Options
% ========
%
% * `'applyTo='` [ cellstr | char | *`@all`* ] - List of variables to which
% the `'filter='` will be applied; `@all` means all variables.
%
% * `'contributions='` [ `true` | *`false`* ] - If `true` the contributions
% of individual shocks to ACFs will be computed and stored in the 5th
% dimension of the `C` and `R` matrices.
%
% * `'filter='` [ char  | *empty* ] - Linear filter that is applied to
% variables specified by 'applyto'.
%
% * `'nFreq='` [ numeric | *`256`* ] - Number of equally spaced frequencies
% over which the filter in the option `'filter='` is numerically
% integrated.
%
% * `'order='` [ numeric | *`0`* ] - Order up to which ACF will be
% computed.
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrices `C`
% and `R` as either [`namedmat`](namedmat/Contents) objects (i.e.
% matrices with named rows and columns) or plain numeric arrays.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return ACF for selected
% variables only; `@all` means all variables.
%
%
% Description
% ============
%
% `C` and `R` are both N-by-N-by-(P+1)-by-NAlt matrices, where N is the
% number of measurement and transition variables (including auxiliary lags
% and leads in the state space vector), P is the order up to which the ACF
% is computed (controlled by the option `'order='`), and NAlt is the number
% of alternative parameterisations in the input model object, `M`.
% 
% If `'contributions=' true`, the size of the two matrices is
% N-by-N-by-(P+1)-by-E-by-NAlt, where E is the number of all  shocks
% (measurement and transition combined) in the model.
%
% ACF with linear filters 
% ------------------------
%
% You can use the option `'filter='` to get the ACF for variables as though
% they were filtered through a linear filter. You can specify the filter in
% both the time domain (such as first-difference filter, or
% Hodrick-Prescott) and the frequncy domain (such as a band of certain
% frequncies or periodicities). The filter is a text string in which you
% can use the following references:
%
% * `'L'`, the lag operator, which will be replaced with `exp(-1i*freq)`;
% * `'per'`, the periodicity;
% * `'freq'`, the frequency.
% 
%
% Example
% ========
%
% A first-difference filter (i.e. computes the ACF for the first
% differences of the respective variables):
%
%     [C, R] = acf(m, 'filter=', '1-L')
%
%
% Example
% ========
%
% The cyclical component of the Hodrick-Prescott filter with the
% smoothing parameter, $lambda$, 1, 600. The formula for the filter follows
% from the classical Wiener-Kolmogorov signal extraction theory, 
%
% $$w(L) = \frac{\lambda}{\lambda + \frac{1}{ | (1-L)(1-L) | ^2}}$$
%
%     [C, R] = acf(m, 'filter', '1600/(1600 + 1/abs((1-L)^2)^2)')
%
%
% Example
% ========
%
% A band-pass filter with user-specified lower and upper bands. The
% band-pass filters can be defined either in frequencies or periodicities;
% the latter is usually more convenient. The following is a filter which
% retains periodicities between 4 and 40 periods (this would be between 1
% and 10 years in a quarterly model), 
%
%     [C, R] = acf(m, 'filter', 'per >= 4 & per <= 40')
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
