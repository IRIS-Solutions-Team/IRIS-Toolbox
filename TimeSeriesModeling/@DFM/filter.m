function [this, d, cc, ff, uu, ee] = filter(this, inp, range, varargin)
% filter  Re-estimate factors by Kalman filtering data taking DFM coefficients as given
%
% __Syntax__
%
%     [A, D, CC, F, U, E] = filter(A, D, Range, ...)
%
%
% __Input Arguments__
%
% * `A` [ DFM ] - Estimated DFM object.
%
% * `a` [ struct | tseries ] - Input database or tseries object with the
% DFM observables.
%
% * `Range` [ numeric ] - Filter date range.
%
%
% __Output Arguments__
%
% * `A` [ DFM ] - DFM object.
%
% * `D` [ struct ] - Output database or tseries object with the DFM
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
% * `Cross=true` [ `true` | `false` | numeric ] - Run the filter with the
% off-diagonal elements in the covariance matrix of idiosyncratic
% residuals; if false all cross-covariances are reset to zero; if a number
% between zero and one, all cross-covariances are multiplied by that
% number.
%
% * `InvFunc='auto'` [ `'auto'` | function_handle ] - Inversion method for
% the FMSE matrices.
%
% * `MeanOnly=false` [ `true` | `false` ] - Return only mean data, i.e.
% point estimates.
%
% * `Persist=false` [ `true` | `false` ] - If `filter` or `forecast` is used
% with `Persist=true` for the first time, the forecast MSE
% matrices and their inverses will be stored; subsequent calls of the
% `filter` or `forecast` functions will re-use these matrices until
% `filter` or `forecast` is called with this option set to `false`.
%
% * `Tolerance=0` [ numeric ] - Numerical tolerance under which two FMSE
% matrices computed in two consecutive periods will be treated as equal and
% their inversions will be re-used, not re-computed.
%
%
% __Description__
%
% It is the user's responsibility to make sure that `filter` and `forecast`
% called with `Persist=` set to true are valid, i.e. that the previously
% computed FMSE matrices can be really re-used in the current run.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('DFM.forecast');
    inputParser.addRequired('a', @(x) isa(x, 'DFM'));
    inputParser.addRequired('InputData', @(x) isa(x, 'Series') || isstruct(x));
    inputParser.addRequired('Range', @isnumeric);
    inputParser.addParameter('Cross', true, ...
        @(x) isequal(x, true) || isequal(x, false) || (isnumeric(x) && isscalar(x) && x>=0 && x<=1));
    inputParser.addParameter('InvFunc', 'auto', @(x) all(strcmpi(x, 'auto')) || isa(x, 'function_handle'));
    inputParser.addParameter('MeanOnly', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Persist', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Tolerance', 0, @(x) isnumeric(x) && isscalar(x));
end
inputParser.parse(this, inp, range, varargin{:});
opt = inputParser.Options;

TEMPLATE_SERIES = Series();


nx = size(this.C, 2);
p = size(this.A, 2)/nx;
range = range(1) : range(end);

% Retrieve and standardize input data
req = datarequest('y*', this, inp, range);
range = req.Range;
y = req.Y;

[this, y] = stdize(this, y);
numPeriods = size(y, 2);

% Initialise Kalman filter.
x0 = zeros(p*nx, 1);
R = this.U(1:nx, :)'*this.B;
indexUnitRoots = this.EigenStability==1;
P0 = covfun.acovf(this.T, R, [ ], [ ], [ ], [ ], this.U, 1, indexUnitRoots, 0);

Sgm = this.Sigma;
% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested.
opt.Cross = double(opt.Cross);
if opt.Cross<1
    posRange = logical(eye(size(Sgm)));
    Sgm(~posRange) = opt.Cross*Sgm(~posRange);
end

% Inversion method for the FMSE matrix. It is safe to use `inv` if
% cross-correlations are pulled down because then the idiosyncratic cov
% matrix is non-singular.
if all(strcmpi(opt.InvFunc, 'auto'))
    if this.Cross==1 && opt.Cross==1
        invFunc = @pinv;
    else
        invFunc = @inv;
    end
else
    invFunc = opt.InvFunc;
end

% __Run VAR Kalman Smoother__
% Run Kalman smoother to re-estimate the common factors taking the
% coefficient matrices as given. If `allobserved` is true then the VAR
% smoother makes an assumption that the factors are uniquely determined
% whenever all observables are available; this is only true if the
% idiosyncratic covariance matrix is not scaled down.
s = struct( );
s.invFunc = invFunc;
s.allObs = this.Cross==1 && opt.Cross==1;
s.tol = opt.Tolerance;
s.reuse = opt.Persist;
s.ahead = 1;

[x, Px, ee, uu, y, Py, ixy] ...
    = iris.mixin.Kalman.smootherForVAR(this, this.A, this.B, [ ], this.C, [ ], 1, Sgm, y, [ ], x0, P0, s);

if opt.MeanOnly
    Px = Px(:, :, [ ], [ ]);
    Py = [ ];
end

if nargout>1
    endogenousNames = this.EndogenousNames;
    [y, Py] = DFM.destdize(y, this.Mean, this.Std, Py);
    d = myoutpdata(this, range, y, Py, endogenousNames);
end

if nargout>2
    % Common components.
    [cc, Pc] = DFM.cc(this.C, x(1:nx, :, :), Px(1:nx, 1:nx, :, :));
    [cc, Pc] = DFM.destdize(cc, this.Mean, this.Std, Pc);
    cc = myoutpdata(this, range, cc, Pc, endogenousNames);
end

if nargout>3
    ff = outputFactorData(this, x, Px, range, ixy, opt);
end

if nargout>4
    uu = DFM.destdize(uu, 0, this.Std);
    uu = myoutpdata(this, range, uu, NaN, endogenousNames);
end

if nargout>5
    ee = replace(TEMPLATE_SERIES, permute(ee, [2, 1, 3]), range(1));
    if ~opt.MeanOnly
        ee = struct( ...
            'mean', ee, ...
            'std', replace(TEMPLATE_SERIES, zeros(0, size(ee, 1), size(ee, 3)), range(1)) ...
        );
    end
end

end
