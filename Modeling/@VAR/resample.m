function [outputData, draws] = resample(this, inp, range, numDraws, varargin)
% resample  Resample from VAR model
%
% __Syntax__
%
%     Outp = resample(V, Inp, Range, NDraw, ...)
%     Outp = resample(V, [ ], Range, NDraw, ...)
%
%
% __Input Arguments__
%
% * `V` [ VAR ] - VAR object to resample from.
%
% * `Inp` [ struct | tseries ] - Input database or tseries used in
% bootstrap; not needed when `'method=' 'montecarlo'`.
%
% * `Range` [ numeric ] - Range for which data will be returned.
%
%
% __Output Arguments__
%
% * `Outp` [ struct | tseries ] - Resampled output database or tseries.
%
%
% __Options__
%
% * `Deviation=false` [ `true` | `false` ] - Do not include the intercept
% in the simulation.
%
% * `Group=NaN` [ numeric | `NaN` ] - Choose group whose parameters will be
% used in resampling; required in VAR objects with multiple groups when
% `Deviation=false`.
%
% * `Method='montecarlo'` [ `'bootstrap'` | `'montecarlo'` |
% function_handle ] - Bootstrap from estimated residuals, resample from
% normal distribution, or use user-supplied sampler.
%
%  `Progress=false` [ `true` | `false` ] - Display progress bar in the
%  command window.
%
%  `Randomize=false` [ `true` | `false` ] - Randomize or fix pre-sample
% initial condition.
%
% * `Wild=false` [ `true` | `false` ] - Use wild bootstrap instead of
% standard Efron bootstrap when `Method='bootstrap'`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

% Panel VAR.
if ispanel(this)
    outputData = mygroupmethod(@resample, this, inp, range, numDraws, varargin{:});
    return
end

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('V', @(x) isa(x, 'VAR'));
pp.addRequired('Inp', @isstruct);
pp.addRequired('Range', @isnumeric);
pp.addRequired('NDraw', @(x) isintscalar(x) && x >= 0);
pp.parse(this, inp, range, numDraws);

% Parse options.
opt = passvalopt('VAR.resample', varargin{:});

if ischar(opt.method)
    opt.method = lower(opt.method);
end

%--------------------------------------------------------------------------

ny = size(this.A, 1);
kx = length(this.NamesExogenous);
p = size(this.A, 2) / max(ny, 1);
nv = size(this.A, 3);

% Check for multiple parameterisations.
chkMultipleParams( );

if isequal(range, Inf)
    range = this.Range(1) + p : this.Range(end);
end

extendedRange = range(1)-p : range(end);
numExtendedPeriods = numel(extendedRange);

% Input data
%------------
req = datarequest('y*, x, e', this, inp, extendedRange);
y = req.Y;
x = req.X;
e = req.E;
nData = size(y, 3);
if nData > 1
    utils.error('VAR:resample', ...
        'Cannot resample from multiple data sets.')
end

% __Pre-allocate an array for resampled data and initialize__
Y = nan(ny, numExtendedPeriods, numDraws);
if opt.Deviation
    Y(:, 1:p, :) = 0;
else
    if isempty(inp)
        % Asymptotic initial condition.
        [~, init] = mean(this);
        Y(:, 1:p, :) = repmat(init, 1, 1, numDraws);
        x = this.X0;
        x = repmat(x, 1, numExtendedPeriods);
        x(:, 1:p) = NaN;
    else
        % Initial condition from pre-sample data.
        Y(:, 1:p, :) = repmat(y(:, 1:p), 1, 1, numDraws);
    end
end

% TODO: randomize initial condition
%{
if options.randomize
else
end
%}

% __System matrices__
[A, ~, K, J] = mysystem(this);
[B, isIdentified] = mybmatrix(this);

% Collect all deterministic terms (constant and exogenous inputs).
KJ = zeros(ny, numExtendedPeriods);
if ~opt.Deviation
    KJ = KJ + repmat(K, 1, numExtendedPeriods);
end
if kx>0
    KJ = KJ + J*x;
end

% Back out reduced-form errors from structural errors if this is a
% structural VAR. The B matrix is then discarded, and only the covariance
% matrix of reduced-form residuals is used.
if isIdentified
    % Structural VAR
    Be = B*e;
else
    % Reduced-form VAR
    Be = e;
end

if ~isequal(opt.method, 'bootstrap')
    % Safely factorize (chol/svd) the covariance matrix of reduced-form
    % residuals so that we can draw from uncorrelated multivariate normal.
    F = covfun.factorise(this.Omega);
    if isa(opt.method, 'function_handle')
        allSampleE = opt.method(ny*(numExtendedPeriods-p), numDraws);
    else
        allSampleE = randn(ny*(numExtendedPeriods-p), numDraws);
    end
end

% Create a command-window progress bar.
if opt.progress
    progress = ProgressBar('IRIS VAR.resample progress');
end

% __Simulate__
ixNanInit = false(1, numDraws);
ixNanResid = false(1, numDraws);
E = nan(ny, numExtendedPeriods, numDraws);
draws = nan(1, numExtendedPeriods, numDraws);
for v = 1 : numDraws
    iBe = zeros(ny, numExtendedPeriods);
    vthDraw = nan(1, numExtendedPeriods);
    [iBe(:, p+1:end), vthDraw(:, p+1:end)] = drawResiduals( );
    iY = Y(:, :, v);
    if any(any(isnan(iY(:, 1:p))))
        ixNanInit(v) = true;
    end
    if any(isnan(iBe(:)))
        ixNanResid(v) = true;
    end
    for t = p+1 : numExtendedPeriods
        iYInit = iY(:, t-(1:p));
        iY(:, t) = A*iYInit(:) + KJ(:, t) + iBe(:, t);
    end
    Y(:, :, v) = iY;
    iE = iBe;
    if isIdentified
        iE = B\iE;
    end
    E(:, p+1:end, v) = iE(:, p+1:end);
    draws(1, :, v) = vthDraw;
    % Update the progress bar.
    if opt.progress
        update(progress, v/numDraws);
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
data = [Y; E];
if kx>0
    names = [names, this.NamesExogenous];
    data = [data; repmat(x, 1, 1, numDraws)];
end
outputData = myoutpdata(this, extendedRange, data, [ ], names);
draws = Series(extendedRange, permute(draws, [2, 3, 1]));

return

    
    function chkMultipleParams( )
        % Works only with single parameterization and single group.
        if nv>1
            utils.error('VAR:resample', ...
                ['Cannot resample from VAR objects ', ...
                'with multiple parameterizations.']);
        end
    end 


    function [X, draw] = drawResiduals( )
        draw = nan(1, numExtendedPeriods-p);
        if isequal(opt.method, 'bootstrap')
            if opt.wild
                % Wild bootstrap.
                % Setting draw = ones(1, nper-p) would reproduce sample.
                draw(1, :) = randn(1, numExtendedPeriods-p);
                X = Be(:, p+1:end).*draw(ones(1, ny), :);
            else
                % Standard Efron bootstrap.
                % Setting draw = 1 : nper-p would reproduce sample;
                % draw is uniform integer [1, nper-p].
                draw(1, :) = randi([1, numExtendedPeriods-p], [1, numExtendedPeriods-p]);
                X = Be(:, p+draw);
            end
        else
            u = allSampleE(:, v);
            u = reshape(u, [ny, numExtendedPeriods-p]);
            X = F*u;
        end
    end 
end

