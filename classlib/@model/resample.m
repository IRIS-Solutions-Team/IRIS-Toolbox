function Outp = resample(varargin)
% resample  Resample from the model implied distribution.
%
% Syntax
% =======
%
% Input arguments marked with a `~` sign may be omitted.
%
%     outp = resample(m, ~inp, range, ~nDraw, ~j, ...)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Solved model object with single parameterization.
%
% * `inp` [ struct | *empty* ] - Input data (if needed) for the
% distributions of initial condition and/or empirical shocks.
%
% * `range` [ numeric | char ] - Resampling date range.
%
% * `~nDraw` [ numeric | *`1`* ] - Number of draws; may be omitted.
%
% * `~j` [ struct | *`[ ]`* ] - Database with user-supplied time-varying
% paths for std deviation, corr coefficients, or medians for shocks; `j`
% is equivalent to using the option `'vary='`, and may be omitted.
%
%
% Output arguments
% =================
%
% * `outp` [ struct ] - Output database with resampled data.
%
%
% Options
% ========
%
% * `'BootstrapMethod='` [ *`'efron'`* | `'wild'` | numeric ] - Numeric
% options correspond to block sampling methods. Use a positive integer to
% specify a fixed block length, or a value strictly between zero and one to
% specify random block lengths based on a geometric distribution.
%
% * `'Deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `'Dtrends='` [ *`@auto`* | `true` | `false` ] - Add deterministic
% trends to measurement variables.
%
% * `'Method='` [ `'bootstrap'` | *`'montecarlo'`* ] - Method of
% randomising shocks and initial condition.
%
% * `'Progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'RandomInitCond='` [ *`true`* | `false` | numeric ] - Randomise
% initial condition; a number means the initial condition will be simulated
% using the specified number of extra pre-sample periods.
%
% * `'StateVector='` [ *`'alpha'`* | `'x'` ] - When resampling initial
% condition, use the transformed state vector, `alpha`, or the vector of
% original variables, `x`; this option is meant to guarantee replicability
% of results.
%
% * `'SvdOnly='` [ `true` | *`false`* ] - Do not attempt Cholesky and only
% use SVD to factorize the covariance matrix when resampling initial
% condition; only applies when `'randomInitCond=' true`.
%
%
% Description
% ============
%
% When you use wild bootstrap for resampling the initial condition, the
% results are based on an assumption that the mean of the initial condition
% is the asymptotic mean implied by the model (i.e. the steady state).
%
%
% References
% ===========
%
% 1. Politis, D. N., & Romano, J. P. (1994). The stationary bootstrap.
% Journal of the American Statistical Association, 89(428), 1303-1313.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

[this, inp, range, nDraw, J, varargin] = ...
    irisinp.parser.parse('model.resample', varargin{:});

% Parse options.
opt = passvalopt('model.resample', varargin{:});

if isempty(opt.wild)
    opt.wild = strcmpi(opt.bootstrapMethod, 'wild') ;
else
    % ##### Jan 2015 OBSOLETE and scheduled for removal.
    utils.warning('obsolete', ...
        ['Option ''wild='' is obsolete, and', ...
        'will be removed from IRIS in a future release. ', ...
        'Use ''bootstrapMethod='' instead.']);
    
    if ~strcmpi(opt.bootstrapMethod, 'wild') && opt.wild
        utils.error('model:resample', ...
            'Cannot combine wild bootstrap with other methods.') ;
    elseif opt.wild
        opt.bootstrapMethod = 'wild' ;
    end
end

% `nInit` is the number of pre-sample periods used to resample the initial
% condition if user does not wish to factorise the covariance matrix.
nInit = 0;
if isnumeric(opt.randominitcond)
    if isequal(opt.method, 'bootstrap') && opt.wild
        utils.error('model:resample', ...
            'Cannot pre-simulate initial conditions in wild bootstrap.');
    else
        nInit = round(opt.randominitcond);
        opt.randominitcond = false;
    end
end

if isequal(opt.method, 'bootstrap') && isempty(inp)
    utils.error('model:resample', ...
        'Cannot bootstrap when there are no input data.');
end

if ischar(opt.method)
    opt.method = lower(opt.method);
end

%--------------------------------------------------------------------------

nPer = length(range);
xRange = range(1)-1 : range(end);

ixd = this.Equation.Type==TYPE(3);
isDTrends = opt.dtrends && any(ixd);
[ny, nxx, nb, nf, ne, ng] = sizeOfSolution(this.Vector);
[T, R, K, Z, H, D, U, Omg] = sspaceMatrices(this, 1, false);
if opt.deviation
    K(:) = 0;
    D(:) = 0;
end

% Pre-allocate output data.
hData = hdataobj(this, xRange, nDraw);

% Return immediately if solution is not available.
if any(isnan(T(:)))
    utils.warning('model:resample', ...
        'Solution(s) not available: #1.');
    % Convert emptpy hdataobj to tseries database.
    Outp = hdata2tseries(hData);
    return
end

nUnit = sum(this.Variant{1}.Stability==TYPE(1));
nStable = nb - nUnit;
Ta = T(nf+1:end, :);
Ra = R(nf+1:end, :);
Ta2 = Ta(nUnit+1:end, nUnit+1:end);
Ra2 = Ra(nUnit+1:end, :);

% Combine user-supplied stdcorr with model stdcorr.
usrStdcorr = varyStdCorr(this, range, J, opt);
usrStdcorrInx = ~isnan(usrStdcorr);

% Get tunes on the mean of shocks.
isShkMean = false;
if ~isempty(J)
    shkMean = datarequest('e', this, J, range, 1);
    isShkMean = any(shkMean(:)~=0);
end

% Get exogenous variables including ttrend.
G = datarequest('g', this, inp, range);

% Describe the distribution of initial conditions
%-------------------------------------------------
if isequal(opt.randominitcond, false)
    Ealp = computeUncMean( );
elseif isequal(opt.method, 'bootstrap')
    % (1) Bootstrap.
    switch opt.bootstrapMethod
        case 'wild'
            % (1a) Wild bootstrap.
            srcAlp0 = datarequest('init', this, inp, range, 1);
            Ealp = computeUncMean( );
        otherwise
            % (1b) Efron or block boostrap.
            srcAlp = datarequest('alpha', this, inp, range, 1);
    end
else
    % (2) Monte Carlo or user-supplied sampler.
    if ~isempty(inp)
        % (2a) User-supplied distribution.
        [Ealp, ~, ~, Palp] = datarequest('init', this, inp, range, 1);
        Ex = U*Ealp;
        if isempty(Palp)
            opt.randominitcond = false;
        else
            if strcmpi(opt.statevector, 'alpha')
                % (2ai) Resample `alpha` vector.
                Falp = covfun.factorise(Palp, opt.svdonly);
            else
                % (2aii) Resample original `x` vector.
                Px = U*Palp*U.';
                Ui = inv(U);
                Fx = covfun.factorise(Px, opt.svdonly);
            end
        end
    else
        % (2b) Asymptotic distribution.
        Ealp = computeUncMean( );
        Falp = zeros(nb);
        Palp = zeros(nb);
        Palp(nUnit+1:end, nUnit+1:end) = covfun.acovf(Ta2, Ra2, ...
            [ ], [ ], [ ], [ ], [ ], Omg, this.Variant{1}.Eigen(nUnit+1:end), 0);
        if strcmpi(opt.statevector, 'alpha')
            % (2bi) Resample the `alpha` vector.
            Falp(nUnit+1:end, nUnit+1:end) = covfun.factorise( ...
                Palp(nUnit+1:end, nUnit+1:end), opt.svdonly);
        else
            % (2bii) Resample the original `x` vector.
            Ex = U*Ealp;
            Px = U*Palp*U.';
            Ui = inv(U);
            Fx = covfun.factorise(Px, opt.svdonly);
        end
    end
end

% Describe the distribution of shocks
%-------------------------------------
if isequal(opt.method, 'bootstrap')
    % (1) Bootstrap.
    srcE = datarequest('e', this, inp, range, 1);
else
    % (2) Monte Carlo.
    % TODO: Use `combineStdCorr` instead.
    vecStdCorr = this.Variant{1}.StdCorr;
    vecStdCorr = permute(vecStdCorr, [2, 3, 1]);
    vecStdCorr = repmat(vecStdCorr, 1, nPer);
    % Combine the model object stdevs with the user-supplied stdevs.
    if any(usrStdcorrInx(:))
        vecStdCorr(usrStdcorrInx) = usrStdcorr(usrStdcorrInx);
    end
    % Add model-object std devs for pre-sample if random initial conditions
    % are obtained by simulation.
    if nInit>0
        vecStdCorr = [vecStdCorr(:, ones(1, nInit)), vecStdCorr];
    end
    
    % Periods in which corr coeffs are all zero. In these periods, we simply
    % mutliply the standard normal shocks by std devs one by one. In all
    % other periods, we need to compute and factorize the entire cov matrix.
    ixZeroCorr = all(vecStdCorr(ne+1:end, :)==0, 1);
    if any(~ixZeroCorr)
        Pe = nan(ne, ne, nInit+nPer);
        Fe = nan(ne, ne, nInit+nPer);
        Pe(:, :, ~ixZeroCorr) = ...
            covfun.stdcorr2cov(vecStdCorr(:, ~ixZeroCorr), ne);
        Fe(:, :, ~ixZeroCorr) = covfun.factorise(Pe(:, :, ~ixZeroCorr));
    end
    
    % If user supplies sampler, sample all shocks and inital conditions at
    % once. This allows for advanced user-supplied simulation methods, e.g.
    % latin hypercube.
    if isa(opt.method, 'function_handle')
        presampledE = opt.method(ne*(nInit+nPer), nDraw);
        if opt.randominitcond
            presampledInitNoise = opt.method(nb, nDraw);
        end
    end
end

% Detect shocks present in measurement and transition equations.
ixR = any(abs(R(:, 1:ne))>0, 1);
ixH = any(abs(H(:, 1:ne))>0, 1);

% Create a command-window progress bar.
if opt.progress
    progress = ProgressBar('IRIS model.resample progress');
end

% Simulate nDraw draws of data
%------------------------------
g = [ ];
for iDraw = 1 : nDraw
    e = drawShocks( );
    if isShkMean
        e = e + shkMean;
    end
    a0 = drawInitCond( );
    % Simulate transition variables.
    w = nan(nxx, nInit+nPer);
    w(:, 1) = T*a0 + R(:, ixR)*e(ixR, 1) + K;
    for t = 2 : nInit+nPer
        w(:, t) = T*w(nf+1:end, t-1) + R(:, ixR)*e(ixR, t) + K;
    end
    % Simulate measurement variables.
    y = Z*w(nf+1:end, nInit+1:end) + H(:, ixH)*e(ixH, nInit+1:end);
    if ~opt.deviation
        y = y + D(:, ones(1, nPer));
    end
    % Add dtrends to simulated data.
    if isDTrends
        if iDraw==1 || ~isequal(G(:, :, min(iDraw, end)), g)
            g = G(:, :, min(iDraw, end));
            W = evalDtrends(this, [ ], g, 1);
        end
        y = y + W;
    end
    % Store this draw.
    storeDraw( );
    % Update the progress bar.
    if opt.progress
        update(progress, iDraw/nDraw);
    end
end

% Convert hdataobj to tseries database.
Outp = hdata2tseries(hData);

return




    function Ealp = computeUncMean( )
        Ealp = zeros(nb, 1);
        if ~opt.deviation
            Kalp2 = K(nf+nUnit+1:end, :);
            Ealp(nUnit+1:end) = (eye(nStable) - Ta2) \ Kalp2;
        end
    end 




    function e = drawShocks( )
        % Resample residuals.
        if isequal(opt.method, 'bootstrap')
            if strcmpi(opt.bootstrapMethod, 'wild')
                % Wild bootstrap
                %----------------
                % `nInit` is always zero for wild boostrap.
                draw = randn(1, nPer);
                % To reproduce input sample: draw = ones(1, nper);
                e = srcE.*draw(ones(1, ne), :);
            elseif isnumeric(opt.bootstrapMethod) ...
                    && opt.bootstrapMethod ~= 1
                % Fixed or random block size
                %----------------------------
                isRandom = ~isintscalar(opt.bootstrapMethod) ;
                bs = NaN;
                if ~isRandom
                    bs = min(nPer, opt.bootstrapMethod) ;
                end
                draw = [ ] ;
                ii = 1 ;
                while ii<=nInit+nPer
                    % Sample block starting point.
                    sPoint = randi([1, nPer], 1) ;
                    if isRandom
                        bs = getRandBlockSize( ) ;
                    end
                    draw = [draw, sPoint:sPoint+bs-1] ; %#ok<AGROW>
                    ii = ii + bs ;
                end
                draw = draw(1:nInit+nPer) ;
                % Take care of references to periods beyond nPer.
                % Make draws circular: nPer+1 -> 1, etc.
                ixBeyond = draw>nPer ;
                while any(ixBeyond)
                    draw(ixBeyond) = draw(ixBeyond) - nPer ;
                    ixBeyond = draw>nPer ;
                end
                e = srcE(:, draw) ;
            else
                % Standard Efron bootstrap
                %--------------------------
                % `draw` is uniform on [1, nper].
                draw = randi([1, nPer], [1, nInit+nPer]);
                % To reproduce input sample: draw = 0 : nper-1;
                e = srcE(:, draw);
            end
        else
            if isa(opt.method, 'function_handle')
                % Fetch and reshape the presampled shocks.
                thisSampleE = presampledE(:, iDraw);
                thisSampleE = reshape(thisSampleE, [ne, nInit+nPer]);
            else
                % Draw shocks from standardised normal.
                thisSampleE = randn(ne, nInit+nPer);
            end
            % Scale standardised normal by the std devs.
            e = zeros(ne, nInit+nPer);
            e(:, ixZeroCorr) = ...
                vecStdCorr(1:ne, ixZeroCorr) .* thisSampleE(:, ixZeroCorr);
            if any(~ixZeroCorr)
                % Cross-corrs are non-zero in some periods.
                for i = find(~ixZeroCorr)
                    e(:, i) = Fe(:, :, i)*thisSampleE(:, i);
                end
            end
        end
    end 




    function a0 = drawInitCond( )
        % Randomise initial condition for stable alpha.
        if isequal(opt.method, 'bootstrap')
            % Bootstrap from empirical distribution.
            if opt.randominitcond
                if opt.wild
                    % Wild-bootstrap initial condition for alpha from given
                    % sample initial condition. This assumes that the mean is
                    % the unconditional distribution.
                    Ealp2 = Ealp(nUnit+1:end);
                    a0 = [ ...
                        srcAlp0(1:nUnit, 1); ...
                        Ealp2 + randn( )*(srcAlp0(nUnit+1:end, 1) - Ealp2); ...
                        ];
                else
                    % Efron-bootstrap init cond for alpha from sample.
                    draw = randi([1, nPer], 1);
                    a0 = srcAlp(:, draw);
                end
            else
                % Fix init cond to unconditional mean.
                a0 = Ealp;
            end
        else
            % Gaussian Monte Carlo from theoretical distribution.
            if opt.randominitcond
                if isa(opt.method, 'function_handle')
                    % Fetch the pre-sampled initial conditions.
                    initNoise = presampledInitNoise(:, iDraw);
                else
                    % Draw from standardised normal.
                    initNoise = randn(nb, 1);
                end
                if strcmpi(opt.statevector, 'alpha')
                    a0 = Ealp + Falp*initNoise;
                else
                    x0 = Ex + Fx*initNoise;
                    a0 = Ui*x0;
                end
            else
                % Fix initial conditions to mean.
                a0 = Ealp;
            end
        end
    end 




    function storeDraw( )
        if nInit==0
            init = a0;
        else
            init = w(nf+1:end, nInit);
        end
        xf = [nan(nf, 1), w(1:nf, nInit+1:end)];
        xb = U*[init, w(nf+1:end, nInit+1:end)];
        hdataassign(hData, iDraw, ...
            { [nan(ny, 1), y], ...
            [xf;xb], ...
            [nan(ne, 1), e(:, nInit+1:end)], ...
            [ ], ...
            [nan(ng, 1), g] });
    end 




    function S = getRandBlockSize( )
        % Block size determined by geo distribution, must be smaller than nPer.
        p = opt.bootstrapMethod ;
        while true
            S = ceil(log(rand)/log(1-p)) ;
            if S<=nPer
                break
            end
        end
    end
end
