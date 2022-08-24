% forecast  Unconditional or conditional VAR forecasts.
%
% Syntax
% =======
%
%     Outp = forecast(V, Inp, Range, ...)
%     Outp = forecast(V, Inp, Range, Cond, ...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% * `Inp` [ struct ] - Input database from which initial condition will be
% read.
%
% * `Range` [ numeric ] - Forecast range; must not refer to `Inf`.
%
% * `Cond` [ struct | tseries ] - Conditioning database with the mean
% values of residuals, reduced-form conditions on endogenous variables, and
% conditioning instruments.
%
% Output arguments
% =================
%
% * `Outp` [ struct ] - Output database with forecasts of endogenous
% variables, residuals, and conditioning instruments.
%
% Options
% ========
%
% * `'cross='` [ numeric | *`1`* ] - Multiply the off-diagonal elements of
% the covariance matrix (cross-covariances) by this factor; `'cross='` must
% be equal to or smaller than `1`.
%
% * `'dbOverlay='` [ `true` | *`false`* ] - Combine the output data with the
% input data; works only if the input data is a database.
%
% * `Deviation=false` [ `true` | `false` ] - Both input and output data are
% deviations from the unconditional mean.
%
% * `'meanOnly='` [ `true` | *`false`* ] - Return a plain database with mean
% forecasts only.
%
% * `'omega='` [ numeric | *empty* ] - Modify the covariance matrix of
% residuals for this forecast.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function outp = forecast(this, inp, range, varargin)

% Panel VAR
if this.IsPanel
    outp = runGroups(@forecast, this, inp, range, varargin{:});
    return
end

cond = [ ];
if ~isempty(varargin) && ~ischar(varargin{1})
    cond = varargin{1};
    varargin(1) = [ ];
end

% Parse input arguments.
pp = inputParser( );
pp.addRequired('V', @(x) isa(this, 'VAR'));
pp.addRequired('Inp', @isstruct);
pp.addRequired('Range', @(x) isnumeric(x) && ~any(isinf(x(:))));
pp.addRequired('Cond', @(x) isempty(x) || isstruct(x));
pp.parse(this, inp, range, cond);


%(
isnumericscalar = @(x) isnumeric(x) && isscalar(x);
islogicalscalar = @(x) islogical(x) && isscalar(x);
defaults = {
    'cross', true, @(x) islogicalscalar(x) || (isnumericscalar(x) && x >=0 && x <= 1)
    'dboverlay, dbextend', false, islogicalscalar
    'Deviation, Deviations', false, islogicalscalar
    'meanonly', false, islogicalscalar
    'omega', [ ], @isnumeric
    'returninstruments, returninstrument', true, islogicalscalar
    'returnresiduals, returnresidual', true, islogicalscalar
    'E', [ ], @(x) isempty(x) || isnumeric(x) 
    'Sigma', [ ], @isnumeric
};
%)

opt = passvalopt(defaults, varargin{1:end});

range = double(range);

%--------------------------------------------------------------------------

ny = size(this.A, 1);
p = size(this.A, 2) / max(ny, 1);
nv = countVariants(this);
kx = this.NumExogenous;
ni = this.NumConditioning;
isExogenous = kx>0;

if isempty(range)
    exception.warning([
        "VAR:EmptyForecastRange"
        "Forecast range is empty."
    ]);
    if opt.meanonly
        inp = [ ];
    else
        inp = struct( );
        inp.mean = [ ];
        inp.std = [ ];
    end
end

if range(1)>range(end)
    % Go backward in time.
    isBackcast = true;
    this = backward(this);
    extdRange = range(end) : range(1)+p;
    range = range(end) : range(1);
else
    isBackcast = false;
    extdRange = range(1)-p : range(end);
end

% Include pre-sample.
req = datarequest('y* x* e', this, inp, extdRange);
extdRange = req.Range;
y = req.Y;
x = req.X;
e = req.E;

e = e(:, p+1:end, :);
if isExogenous
    x = x(:, p+1:end, :);
end

% Get tunes on VAR variables and instruments; do not include pre-sample.
if ~isstruct(cond)
    cond = struct( );
end
req = datarequest('y e i', this, cond, range);
condEndogenous = req.Y;
condE = req.E;
condInstrument = req.I;

% Changes in residual means can be either in `e` or `je` (but not both).
e(isnan(e)) = 0;
condE(isnan(condE)) = 0;
if any( condE(:)~=0 )
    if any( e(:)~=0 )
        exception.error([
            "VAR:InconsistentInputResiduals"
            "Changes in the mean values of residuals can be entered either " 
            "in the input database or in the conditioning database, " 
            "but not in both."
        ]);
    else
        e = condE;
    end
end

if isBackcast
    y = flip(y, 2);
    x = flip(x, 2);
    e = flip(e, 2);
    condEndogenous = flip(condEndogenous, 2);
    condInstrument = flip(condInstrument, 2);
end

numPeriods = length(range);
numExtdPeriods = length(extdRange);
nDataY = size(y, 3);
nDataX = size(x, 3);
nDataE = size(e, 3);
nCond = size(condEndogenous, 3);
nInst = size(condInstrument, 3);
nOmg = size(opt.omega, 3);
nE = size(opt.E, 3);

numRuns = max([nv, nDataY, nDataX, nDataE, nCond, nInst, nOmg, nE]);

% Stack initial conditions.
y0 = y(:, 1:p, :);
y0 = y0(:, p:-1:1, :);
y0 = reshape(y0(:), ny*p, size(y0, 3));

% Preallocate output data.
Y = nan(ny, numExtdPeriods, numRuns);
X = nan(kx, numExtdPeriods, numRuns);
E = nan(ny, numExtdPeriods, numRuns);
P = zeros(ny, ny, numExtdPeriods, numRuns);
I = nan(ni, numExtdPeriods, numRuns);


s = struct( );
s.invFunc = @inv;
s.allObs = NaN;
s.tol = 0;
s.reuse = false;
s.ahead = 1;

for iLoop = 1 : numRuns
    
    [A__, B__, K__, J__, Zi__, Omega__] = getIthSystem(this, min(iLoop, nv));
    
    if ~isempty(opt.omega)
        Omega__(:, :) = opt.omega(:, :, min(iLoop, end));
    end
        
    % Reduce or zero off-diagonal elements in the cov matrix of residuals
    % if requested. This only matters in VARs, not SVARs.
    if double(opt.cross)<1
        inx = logical( eye(size(Omega__)) );
        Omega__(~inx) = double(opt.cross)*Omega__(~inx);
    end
    
    % Use the `allObserved` option in `@iris.mixin.Kalman/smootherForVAR` only if the cov matrix is
    % full rank. Otherwise, there is singularity.
    s.allObs = rank(Omega__)==ny;

    % Get the iLoop-th data
    y0__ = y0(:, min(iLoop, end));
    if isExogenous
        X__ = x(:, :, min(iLoop, end));
    end

    if isempty(opt.E)
        E__ = e(:, :, min(iLoop, end));
    else
        E__ = opt.E(:, :, min(iLoop, end));
    end
    condEndogenous__ = condEndogenous(:, :, min(iLoop, end));
    condInstrument__ = condInstrument(:, :, min(iLoop, end));

    if ~isempty(condInstrument__)
        Z__ = [eye(ny, ny*p); Zi__(:, 2:end)];
        D__ = [zeros(ny, 1); Zi__(:, 1)];
        s.allObs = false;
    else
        Z__ = eye(ny);
        D__ = [ ];
    end

    % Collect all deterministic terms (constant and exogenous inputs)
    KK__ = zeros(ny, numPeriods);
    if ~opt.Deviation
        KK__ = KK__ + repmat(K__, 1, numPeriods);
    end    
    if isExogenous
        KK__ = KK__ + J__*X__;
    end
    
    % Run Kalman filter and smoother
    [~, ~, E__, ~, iY, iP] = iris.mixin.Kalman.smootherForVAR( ...
        this, A__, B__, KK__, Z__, D__, Omega__, ...
        [ ], [condEndogenous__; condInstrument__], E__, y0__, 0, s ...
    );
    
    E(:, p+1:end, iLoop) = E__;
    % Add pre-sample initial condition.
    Y(:, p:-1:1, iLoop) = reshape(y0__, ny, p);
    % Add forecast data; `iY` includes both the VAR variables and the
    % instruments.
    Y(:, p+1:end, iLoop) = iY(1:ny, :);
    if isExogenous
        X(:, p+1:end, iLoop) = X__;
    end
    P(:, :, p+1:end, iLoop) = iP(1:ny, 1:ny, :);
    % Return conditioning instruments.
    I(:, p+1:end, iLoop) = iY(ny+1:end, :);
end

if isBackcast
    Y = flip(Y, 2);
    E = flip(E, 2);
    if isExogenous
        X = flip(X, 2);
    end
    I = flip(I, 2);
    P = flip(X, 3);
end

% Prepare output data
allNames = this.AllNames; 
data = [Y; X; E; I];

% Output data for endougenous variables, residuals, and instruments.
if opt.meanonly
    outp = myoutpdata(this, extdRange, data, [ ], allNames);
    if opt.dboverlay
        if ~isfield(inp, 'mean')
            outp = dboverlay(inp, outp);
        else
            outp = dboverlay(inp.mean, outp);
        end
    end
else
    outp = myoutpdata(this, extdRange, data, P, allNames);
    if opt.dboverlay
        if ~isfield(inp, 'mean')
            outp.mean = dboverlay(inp, outp.mean);
        else
            outp.mean = dboverlay(inp.mean, outp.mean);
        end
    end    
end

end%

