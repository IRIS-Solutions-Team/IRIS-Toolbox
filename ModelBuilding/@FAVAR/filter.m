function [this, d, cc, ff, uu, ee] = filter(this, inp, range, varargin)
% filter  Re-estimate factors by Kalman filtering data taking FAVAR coefficients as given
%
% __Syntax__
%
%     [A, D, CC, F, U, E] = filter(A, D, Range, ...)
%
%
% __Input Arguments__
%
% * `A` [ FAVAR ] - Estimated FAVAR object.
%
% * `a` [ struct | tseries ] - Input database or tseries object with the
% FAVAR observables.
%
% * `Range` [ numeric ] - Filter date range.
%
%
% __Output Arguments__
%
% * `A` [ FAVAR ] - FAVAR object.
%
% * `D` [ struct ] - Output database or tseries object with the FAVAR
% observables.
%
% * `CC` [ struct | Series | tseries ] - Re-estimated common components in the
% observables.
%
% * `F` [ Series | tseries ] - Re-estimated common factors.
%
% * `U` [ Series | tseries ] - Re-estimated idiosyncratic residuals.
%
% * `E` [ Series | tseries ] - Re-estimated structural residuals.
%
%
% __Options__
%
% * `'Cross='` [ *`true`* | `false` | numeric ] - Run the filter with the
% off-diagonal elements in the covariance matrix of idiosyncratic
% residuals; if false all cross-covariances are reset to zero; if a number
% between zero and one, all cross-covariances are multiplied by that
% number.
%
% * `'InvFunc='` [ *`'auto'`* | function_handle ] - Inversion method for
% the FMSE matrices.
%
% * `'MeanOnly='` [ `true` | *`false`* ] - Return only mean data, i.e. point
% estimates.
%
% * `'Persist='` [ `true` | *`false`* ] - If `filter` or `forecast` is used
% with `'Persist='` set to `true` for the first time, the forecast MSE
% matrices and their inverses will be stored; subsequent calls of the
% `filter` or `forecast` functions will re-use these matrices until
% `filter` or `forecast` is called with this option set to `false`.
%
% * `'Tolerance='` [ numeric | *`0`* ] - Numerical tolerance under which
% two FMSE matrices computed in two consecutive periods will be treated as
% equal and their inversions will be re-used, not re-computed.
%
%
% __Description__
%
% It is the user's responsibility to make sure that `filter` and `forecast`
% called with `'Persist='` set to true are valid, i.e. that the
% previously computed FMSE matrices can be really re-used in the current
% run.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );

% Parse input arguments.
pp = inputParser( );
pp.addRequired('A', @(x) isa(x, 'FAVAR'));
pp.addRequired('D', @(x) isstruct(x) || isa(x, 'tseries'));
pp.addRequired('Range', @isnumeric);
pp.parse(this, inp, range);

% Parse options.
opt = passvalopt('FAVAR.filter', varargin{:});

%--------------------------------------------------------------------------

nx = size(this.C, 2);
p = size(this.A, 2)/nx;
range = range(1) : range(end);

% Retrieve and standardise input data.
req = datarequest('y*', this, inp, range);
range = req.Range;
y = req.Y;

[this, y] = standardise(this, y);
nPer = size(y, 2);

% Initialise Kalman filter.
x0 = zeros([p*nx, 1]);
R = this.U(1:nx, :)'*this.B;
P0 = covfun.acovf(this.T, R, [ ], [ ], [ ], [ ], this.U, 1, [ ], 0);

Sgm = this.Sigma;
% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested.
opt.cross = double(opt.cross);
if opt.cross<1
    posRange = logical(eye(size(Sgm)));
    Sgm(~posRange) = opt.cross*Sgm(~posRange);
end

% Inversion method for the FMSE matrix. It is safe to use `inv` if
% cross-correlations are pulled down because then the idiosyncratic cov
% matrix is non-singular.
if isequal(opt.invfunc, 'auto')
    if this.Cross==1 && opt.cross==1
        invFunc = @pinv;
    else
        invFunc = @inv;
    end
else
    invFunc = opt.invfunc;
end

% Run VAR Kalman smoother
%-------------------------
% Run Kalman smoother to re-estimate the common factors taking the
% coefficient matrices as given. If `allobserved` is true then the VAR
% smoother makes an assumption that the factors are uniquely determined
% whenever all observables are available; this is only true if the
% idiosyncratic covariance matrix is not scaled down.
s = struct( );
s.invFunc = invFunc;
s.allObs = this.Cross==1 && opt.cross==1;
s.tol = opt.tolerance;
s.reuse = opt.persist;
s.ahead = 1;

[x, Px, ee, uu, y, Py, ixy] = timedom.varsmoother( ...
    this.A, this.B, [ ], this.C, [ ], 1, Sgm, y, [ ], x0, P0, s);

if opt.meanonly
    Px = Px(:, :, [ ], [ ]);
    Py = [ ];
end

if nargout>1
    lsy = get(this, 'YNames');
    [y, Py] = FAVAR.destandardise(this.Mean, this.Std, y, Py);
    d = myoutpdata(this, range, y, Py, lsy);
end

if nargout>2
    % Common components.
    [cc, Pc] = FAVAR.cc(this.C, x(1:nx, :, :), Px(1:nx, 1:nx, :, :));
    [cc, Pc] = FAVAR.destandardise(this.Mean, this.Std, cc, Pc);
    cc = myoutpdata(this, range, cc, Pc, lsy);
end

if nargout>3
    ff = outputFactorData(this, x, Px, range, ixy, opt);
end

if nargout>4
    uu = FAVAR.destandardise(0, this.Std, uu);
    uu = myoutpdata(this, range, uu, NaN, lsy);
end

if nargout>5
    ee = replace(TEMPLATE_SERIES, permute(ee, [2, 1, 3]), range(1));
    if ~opt.meanonly
        ee = struct( ...
            'mean', ee, ...
            'std', replace(TEMPLATE_SERIES, zeros([0, size(ee, 1), size(ee, 3)]), range(1)) ...
            );
    end
end

end
