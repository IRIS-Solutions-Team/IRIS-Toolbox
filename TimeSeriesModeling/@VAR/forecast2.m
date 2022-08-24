function outp = forecast(this, inp, range, varargin)
% forecast  Unconditional or conditional VAR forecasts.
%
% Syntax
% =======
%
%     Outp = forecast(V,Inp,Range,...)
%     Outp = forecast(V,Inp,Range,Cond,...)
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
% * `Cross=1` [ numeric ] - Multiply the off-diagonal elements of the
% covariance matrix (cross-covariances) by this factor; `Cross=` must be
% equal to or smaller than `1`.
%
%  `DbOverlay=false` [ `true` | `false` ] - Combine the output data with the
% input data; works only if the input data is a database.
%
% `Deviation=false` [ `true` | `false` ] - Both input and output data are
% deviations from the unconditional mean.
%
%  `MeanOnly=false` [ `true` | `false` ] - Return a plain database with mean
% forecasts only.
%
% * `Omega=[ ]` [ numeric ] - Modify the covariance matrix of residuals for
% this forecast.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

isnumericscalar = @(x) isnumeric(x) && isscalar(x);

% Panel VAR.
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
pp.addRequired('Inp',@isstruct);
pp.addRequired('Range', @(x) isnumeric(x) && ~any(isinf(x(:))));
pp.addRequired('Cond', @(x) isempty(x) || isstruct(x));
pp.parse(this, inp, range, cond);


islogicalscalar = @(x) islogical(x) && isscalar(x);
%(
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

%--------------------------------------------------------------------------

ny = size(this.A, 1);
p = size(this.A, 2) / max(ny, 1);
nAlt = size(this.A, 3);
kx = length(this.ExogenousNames);
ni = size(this.Zi, 1);
isX = kx>0;

if isempty(opt.Sigma)
    Sigma = zeros(ny);
else
    opt.Sigma = opt.Sigma(:);
    if length(opt.Sigma)<ny
        opt.Sigma(end+1:ny) = 0;
    end
    Sigma = diag(opt.Sigma);
end

if isempty(range)
    utils.warning('VAR:forecast', ...
        'Forecast range is empty.');
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
    xRange = range(end) : range(1)+p;
    range = range(end) : range(1);
else
    isBackcast = false;
    xRange = range(1)-p : range(end);
end

% Include pre-sample.
req = datarequest('y* x* e', this, inp, xRange);
xRange = req.Range;
y = req.Y;
x = req.X;
e = req.E;

e = e(:, p+1:end,:);
if isX
    x = x(:, p+1:end,:);
end

% Get tunes on VAR variables and instruments; do not include pre-sample.
if ~isstruct(cond)
    cond = struct( );
end
req = datarequest('y e i', this, cond, range);
condY = req.Y;
condE = req.E;
condI = req.I;

% Changes in residual means can be either in `e` or `je` (but not both).
e(isnan(e)) = 0;
condE(isnan(condE)) = 0;
if any( condE(:)~=0 )
    if any( e(:)~=0 )
        utils.error('VAR:forecast', ...
            ['Changes in residual means can be entered either ', ...
            'in the input database or in the conditioning database, ', ...
            'but not in both.']);
    else
        e = condE;
    end
end

if isBackcast
    y = flip(y, 2);
    x = flip(x, 2);
    e = flip(e, 2);
    condY = flip(condY, 2);
    condI = flip(condI, 2);
end

nPer = length(range);
nXPer = length(xRange);
nDataY = size(y, 3);
nDataX = size(x, 3);
nDataE = size(e, 3);
nCond = size(condY, 3);
nInst = size(condI, 3);
nOmg = size(opt.omega, 3);
nE = size(opt.E, 3);

nLoop = max([nAlt, nDataY, nDataX, nDataE, nCond, nInst, nOmg, nE]);

% Stack initial conditions.
y0 = y(:, 1:p,:);
y0 = y0(:,p:-1:1,:);
y0 = reshape(y0(:), ny*p,size(y0, 3));

% Preallocate output data.
Y = nan(ny, nXPer, nLoop);
X = nan(kx, nXPer, nLoop);
E = nan(ny, nXPer, nLoop);
P = zeros(ny, ny, nXPer, nLoop);
I = nan(ni, nXPer, nLoop);

Zi = this.Zi;
if isempty(Zi)
    Zi = zeros(0, 1+ny*p);
end

s = struct( );
s.invFunc = @inv;
s.allObs = NaN;
s.tol = 0;
s.reuse = false;
s.ahead = 1;

for iLoop = 1 : nLoop
    [iA, iB, iK, iJ, ~, iOmg] = getIthSystem(this, min(iLoop, nAlt));
    
    if ~isempty(opt.omega)
        iOmg(:,:) = opt.omega(:,:, min(iLoop, end));
    end
        
    % Get the iLoop-th data.
    iY0 = y0(:, min(iLoop, end));

    if isempty(opt.E)
        iE = e(:,:, min(iLoop, end));
    else
        iE = opt.E(:, :, min(iLoop, end));
    end
    iCondY = condY(:, :, min(iLoop, end));

    iY = VAR.smoother(iY0, iCondY, iA, iK, iE, iOmg, Sigma);

    % Add pre-sample initial condition.
    Y(:,p:-1:1, iLoop) = reshape(iY0, ny,p);
    Y(:,p+1:end, iLoop) = iY;
end

outp = myoutpdata(this, xRange, Y, [ ], this.EndogenousNames);
if opt.dboverlay
    outp = dboverlay(inp, outp);
end

end%

