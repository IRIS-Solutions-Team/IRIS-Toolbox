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
% * `'cross='` [ numeric | *`1`* ] - Multiply the off-diagonal elements of
% the covariance matrix (cross-covariances) by this factor; `'cross='` must
% be equal to or smaller than `1`.
%
% * `'dbOverlay='` [ `true` | *`false`* ] - Combine the output data with the
% input data; works only if the input data is a database.
%
% * `'deviation='` [ `true` | *`false`* ] - Both input and output data are
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
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% Panel VAR.
if ispanel(this)
    outp = mygroupmethod(@forecast, this, inp, range, varargin{:});
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

% Parse options.
opt = passvalopt('VAR.forecast',varargin{1:end});

%--------------------------------------------------------------------------

ny = size(this.A, 1);
p = size(this.A, 2) / max(ny, 1);
nAlt = size(this.A, 3);
kx = length(this.NamesExogenous);
ni = size(this.Zi, 1);
isX = kx>0;

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
    
    [iA, iB, iK, iJ, iOmg] = mysystem(this, min(iLoop, nAlt));
    
    if ~isempty(opt.omega)
        iOmg(:,:) = opt.omega(:,:, min(iLoop, end));
    end
        
    % Reduce or zero off-diagonal elements in the cov matrix of residuals
    % if requested. This only matters in VARs, not SVARs.
    if double(opt.cross)<1
        ix = logical( eye(size(iOmg)) );
        iOmg(~ix) = double(opt.cross)*iOmg(~ix);
    end
    
    % Use the `allObserved` option in `varsmoother` only if the cov matrix is
    % full rank. Otherwise, there is singularity.
    s.allObs = rank(iOmg)==ny;

    % Get the iLoop-th data.
    iY0 = y0(:, min(iLoop, end));
    if isX
        iX = x(:, :, min(iLoop, end));
    end

    if isempty(opt.E)
        iE = e(:,:, min(iLoop, end));
    else
        iE = opt.E(:, :, min(iLoop, end));
    end
    iCondY = condY(:, :, min(iLoop, end));
    iCondI = condI(:, :, min(iLoop, end));

    if ~isempty(iCondI)
        Z = [eye(ny, ny*p); Zi(:, 2:end)];
        D = [zeros(ny, 1); Zi(:, 1)];
        s.allObs = false;
    else
        Z = eye(ny);
        D = [ ];
    end

    % Collect all deterministic terms (constant and exogenous inputs).
    iKJ = zeros(ny, nPer);
    if ~opt.deviation
        iKJ = iKJ + repmat(iK, 1, nPer);
    end    
    if isX
        iKJ = iKJ + iJ*iX;
    end
    
    % Run Kalman filter and smoother.
    [~,~, iE,~, iY, iP] = ...
        timedom.varsmoother(iA, iB, iKJ, Z, D, iOmg, ...
        [ ], [iCondY;iCondI], iE, iY0,0,s);
    
    E(:,p+1:end, iLoop) = iE;
    % Add pre-sample initial condition.
    Y(:,p:-1:1, iLoop) = reshape(iY0, ny,p);
    % Add forecast data; `iY` includes both the VAR variables and the
    % instruments.
    Y(:,p+1:end, iLoop) = iY(1:ny,:);
    if isX
        X(:,p+1:end, iLoop) = iX;
    end
    P(:,:,p+1:end, iLoop) = iP(1:ny, 1:ny,:);
    % Return conditioning instruments.
    I(:,p+1:end, iLoop) = iY(ny+1:end,:);
end

if isBackcast
    Y = flip(Y, 2);
    E = flip(E, 2);
    if isX
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
    outp = myoutpdata(this, xRange, data, [ ], allNames);
    if opt.dboverlay
        if ~isfield(inp, 'mean')
            outp = dboverlay(inp, outp);
        else
            outp = dboverlay(inp.mean, outp);
        end
    end
else
    outp = myoutpdata(this, xRange, data, P, allNames);
    if opt.dboverlay
        if ~isfield(inp, 'mean')
            outp.mean = dboverlay(inp, outp.mean);
        else
            outp.mean = dboverlay(inp.mean, outp.mean);
        end
    end    
end

end
