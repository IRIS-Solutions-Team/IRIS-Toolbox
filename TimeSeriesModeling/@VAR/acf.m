function [C, Q] = acf(this, varargin)
% acf  Autocovariance and autocorrelation functions for VAR variables
%
% __Syntax__
%
%     [C, R] = acf(VARModel, ...)
%
%
% __Input Arguments__
%
% * `VARModel` [ VAR ] - VAR object for which the ACF will be computed.
%
%
% __Output Arguments__
%
% * `C` [ namedmat | numeric ] - Auto/cross-covariance matrices.
%
% * `R` [ namedmat | numeric ] - Auto/cross-correlation matrices.
%
%
% __Options__
%
% * `ApplyTo=@all` [ logical | `@all` ] - Logical index of variables to
% which the `Filter=` will be applied; `@all` means all variables.
%
% * `Filter=''` [ char  ] - Linear filter that is applied to variables
% specified by 'ApplyTo='.
%
% * `MatrixFormat='NamedMat'` [ `'NamedMat'` | `'Plain'` ] - Return
% matrices `C` and `R` as either [`namedmat`](namedmat/Contents) objects
% (i.e.  matrices with named rows and columns) or plain numeric arrays.
%
% * `NFreq=256` [ numeric ] - Number of equally spaced frequencies
% over which the `'filter='` is numerically integrated.
%
% * `Order=0` [ numeric ] - Order up to which ACF will be
% computed.
%
% * `Progress=false` [ `true` | `false` ] - Display progress bar in the
% command window.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team


isnumericscalar = @(x) isnumeric(x) && isscalar(x);
islogicalscalar = @(x) islogical(x) && isscalar(x);
defaults = {
    'ApplyTo', @all, @(x) isnumeric(x) || islogical(x) || isequal(x, @all) || iscellstr(x)
    'Filter', '', @(x) ischar(x) || isstring(x)
    'MatrixFormat', 'namedmat', @validate.matrixFormat
    'NFreq', 256, isnumericscalar
    'Order', 0, isnumericscalar
    'Progress', false, islogicalscalar
}; %#ok<*CCAT>

opt = passvalopt(defaults, varargin{:});


returnCorrelations = nargout>1;
isNamedMat = strcmpi(opt.MatrixFormat, 'namedmat');

%--------------------------------------------------------------------------

ny = size(this.A, 1);
p = size(this.A, 2) / max(ny, 1);
nv = size(this.A, 3);
maxOrder = opt.Order;

% Preprocess filter options
[isFilter, filter, freq, applyTo] = freqdom.applyfilteropt(opt, [ ], this.EndogenousNames);

C = nan(ny, ny, maxOrder+1, nv);

% Find explosive parameterisations.
inxOfUnstable = isexplosive(this);

if opt.Progress
    pBar = ProgressBar('[IrisToolbox] @VAR/acf Progress');
end

for v = find(~inxOfUnstable)
    [T, R, ~, ~, ~, ~, U, Omega] = sspace(this, v);
    eigenStability = this.EigenStability(:, :, v);
    indexUnitRoots = eigenStability==1;
    if isFilter
        S = freqdom.xsfvar(this.A(:, :, v), Omega, freq, filter, applyTo);
        C(:, :, :, v) = freqdom.xsf2acf(S, freq, maxOrder);
    else
        % Compute contemporaneous ACF for its first-order state space form.
        % this gives us autocovariances up to order p-1.
        c = covfun.acovf(T, R, [ ], [ ], [ ], [ ], U, Omega, indexUnitRoots, 0);
        if p > 1
            c0 = c;
            c = reshape(c0(1:ny, :), ny, ny, p);
        end
        if p==0
            c(:, :, end+1:maxOrder+1) = 0;
        elseif maxOrder>p-1
            % Compute higher-order acfs using Yule-Walker equations.
            c = yuleWalker(this.A(:, :, v), c, maxOrder);
        else
            c = c(:, :, 1:1+maxOrder);
        end
        C(:, :, :, v) = c;
    end
    % Update the progress bar.
    if opt.Progress
        update(pBar, v/sum(~inxOfUnstable));
    end
end

if any(inxOfUnstable)
    throw( ...
        exception.Base('VAR:CannotHandleUnstable', 'warning'), ...
        'ACF', exception.Base.alt2str(inxOfUnstable) ...
    );
end

% Fix entries with negative variances
C = timedom.fixcov(C, this.Tolerance.Mse);

% Autocorrelation function
if returnCorrelations
    % Convert covariances to correlations
    Q = covfun.cov2corr(C);
end

% Convert double arrays to namedmat objects if requested.
if isNamedMat
    C = namedmat(C, this.EndogenousNames, this.EndogenousNames);
    try %#ok<TRYNC>
        Q = namedmat(Q, this.EndogenousNames, this.EndogenousNames);
    end
end

end%


function C = yuleWalker(A, C, P)
    [ny, pNy] = size(A);
    p = pNy/ny;

    % Residuals included or not in ACF.
    ne = size(C, 1) - ny;

    A = reshape(A(:, 1:ny*p), ny, ny, p);
    C = C(:, :, 1+(0:p-1));
    for i = p : P
        X = zeros(ny, ny+ne);
        for j = 1 : size(A, 3)
            X = X + A(:, :, j)*C(1:ny, :, end-j+1);
        end
        C(1:ny, :, 1+i) = X;
    end
end%

