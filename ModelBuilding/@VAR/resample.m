function outp = resample(this, inp, range, nDraw, varargin)
% resample  Resample from a VAR object.
%
% Syntax
% =======
%
%     Outp = resample(V,Inp,Range,NDraw,...)
%     Outp = resample(V,[ ],Range,NDraw,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object to resample from.
%
% * `Inp` [ struct | tseries ] - Input database or tseries used in
% bootstrap; not needed when `'method=' 'montecarlo'`.
%
% * `Range` [ numeric ] - Range for which data will be returned.
%
% Output arguments
% =================
%
% * `Outp` [ struct | tseries ] - Resampled output database or tseries.
%
% Options
% ========
%
% * `'deviation='` [ `true` | *`false`* ] - Do not include the constant
% term in simulations.
%
% * `'group='` [ numeric | *`NaN`* ] - Choose group whose parameters will
% be used in resampling; required in VAR objects with multiple groups when
% `'deviation=' false`.
%
% * `'method='` [ `'bootstrap'` | *`'montecarlo'`* | function_handle ] -
% Bootstrap from estimated residuals, resample from normal distribution, or
% use user-supplied sampler.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'randomise='` [ `true` | *`false`* ] - Randomise or fix pre-sample
% initial condition.
%
% * `'wild='` [ `true` | *`false`* ] - Use wild bootstrap instead of
% standard Efron bootstrap when `'method=' 'bootstrap'`.
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
    outp = mygroupmethod(@resample, this, inp, range, nDraw, varargin{:});
    return
end

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('V',@(x) isa(x, 'VAR'));
pp.addRequired('Inp', @isstruct);
pp.addRequired('Range', @isnumeric);
pp.addRequired('NDraw', @(x) isintscalar(x) && x >= 0);
pp.parse(this, inp, range, nDraw);

% Parse options.
opt = passvalopt('VAR.resample', varargin{:});

if ischar(opt.method)
    opt.method = lower(opt.method);
end

%--------------------------------------------------------------------------

ny = size(this.A,1);
kx = length(this.NamesExogenous);
p = size(this.A,2) / max(ny,1);
nAlt = size(this.A,3);

% Check for multiple parameterisations.
chkMultipleParams( );

if isequal(range, Inf)
    range = this.Range(1) + p : this.Range(end);
end

xRange = range(1)-p : range(end);
nXPer = numel(xRange);

% Input data
%------------
req = datarequest('y*,x,e', this, inp, xRange);
y = req.Y;
x = req.X;
e = req.E;
nData = size(y,3);
if nData > 1
    utils.error('VAR:resample', ...
        'Cannot resample from multiple data sets.')
end

% Pre-allocate an array for resampled data and initialise
%---------------------------------------------------------
Y = nan(ny, nXPer, nDraw);
if opt.deviation
    Y(:, 1:p, :) = 0;
else
    if isempty(inp)
        % Asymptotic initial condition.
        [~, init] = mean(this);
        Y(:, 1:p, :) = repmat(init, 1, 1, nDraw);
        x = this.X0;
        x = repmat(x, 1, nXPer);
        x(:, 1:p) = NaN;
    else
        % Initial condition from pre-sample data.
        Y(:, 1:p, :) = repmat(y(:,1:p), 1, 1, nDraw);
    end
end

% TODO: randomise initial condition
%{
if options.randomise
else
end
%}

% System matrices
%-----------------
[A, ~, K, J] = mysystem(this);
[B, isIdentified] = mybmatrix(this);

% Collect all deterministic terms (constant and exogenous inputs).
KJ = zeros(ny, nXPer);
if ~opt.deviation
    KJ = KJ + repmat(K, 1, nXPer);
end
if kx>0
    KJ = KJ + J*x;
end

% Back out reduced-form residuals if needed. The B matrix is then
% discarded, and only the covariance matrix of reduced-form residuals is
% used.
if isIdentified
    Be = B*e;
end

if ~isequal(opt.method,'bootstrap')
    % Safely factorise (chol/svd) the covariance matrix of reduced-form
    % residuals so that we can draw from uncorrelated multivariate normal.
    F = covfun.factorise(this.Omega);
    if isa(opt.method, 'function_handle')
        allSampleE = opt.method(ny*(nXPer-p), nDraw);
    else
        allSampleE = randn(ny*(nXPer-p), nDraw);
    end
end

% Create a command-window progress bar.
if opt.progress
    progress = ProgressBar('IRIS VAR.resample progress');
end

% Simulate
%----------
ixNanInit = false(1, nDraw);
ixNanResid = false(1, nDraw);
E = nan(ny, nXPer, nDraw);
for iDraw = 1 : nDraw
    iBe = zeros(ny, nXPer);
    iBe(:, p+1:end) = drawResiduals( );
    iY = Y(:,:,iDraw);
    if any(any(isnan(iY(:,1:p))))
        ixNanInit(iDraw) = true;
    end
    if any(isnan(iBe(:)))
        ixNanResid(iDraw) = true;
    end
    for t = p+1 : nXPer
        iYInit = iY(:, t-(1:p));
        iY(:, t) = A*iYInit(:) + KJ(:, t) + iBe(:, t);
    end
    Y(:,:,iDraw) = iY;
    iE = iBe;
    if isIdentified
        iE = B\iE;
    end
    E(:, p+1:end,iDraw) = iE(:, p+1:end);
    % Update the progress bar.
    if opt.progress
        update(progress,iDraw/nDraw);
    end
end

% Report NaNs in initial conditions.
if any(ixNanInit)
    utils.warning('VAR:resample', ...
        'Some of the initial conditions for resampling are NaN %s.', ...
        exception.Base.alt2str(ixNanInit) );
end

% Report NaNs in resampled residuals.
if any(ixNanResid)
    utils.warning('VAR:resample', ...
        'Some of the resampled residuals are NaN %s.', ...
        exception.Base.alt2str(ixNanResid) );
end

% Return only endogenous variables, not shocks.
names = [this.NamesEndogenous, this.NamesErrors];
data = [Y;E];
if kx > 0
    names = [names, this.NamesExogenous];
    data = [data; repmat(x, 1, 1, nDraw)];
end
outp = myoutpdata(this, xRange, data, [ ], names);

return



    
    function chkMultipleParams( )
        % Works only with single parameterisation and single group.
        if nAlt>1
            utils.error('VAR:resample', ...
                ['Cannot resample from VAR objects ', ...
                'with multiple parameterisations.']);
        end
    end 




    function X = drawResiduals( )
        if isequal(opt.method, 'bootstrap')
            if opt.wild
                % Wild bootstrap.
                % Setting draw = ones(1, nper-p) would reproduce sample.
                draw = randn(1, nXPer-p);
                X = Be(:, p+1:end).*draw(ones(1, ny), :);
            else
                % Standard Efron bootstrap.
                % Setting draw = 1 : nper-p would reproduce sample;
                % draw is uniform integer [1, nper-p].
                draw = randi([1, nXPer-p], [1, nXPer-p]);
                X = Be(:, p+draw);
            end
        else
            u = allSampleE(:, iDraw);
            u = reshape(u, [ny, nXPer-p]);
            X = F*u;
        end
    end 
end

