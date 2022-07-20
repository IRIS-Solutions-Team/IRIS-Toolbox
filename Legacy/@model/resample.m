% resample  Resample from the model implied distribution.
%
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted.
%
%     Outp = resample(M, ~Inp, Range, ~NDraw, ~J, ...)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Solved model object with single parameterization.
%
% * `~Inp=[ ]` [ struct | empty ] - Input data (if needed) for the distributions of
% initial condition and/or empirical shocks.
%
% * `Range` [ DateWrapper ] - Resampling date range.
%
% * `~NDraw=1` [ numeric ] - Number of draws; may be omitted.
%
%
% ## Output Arguments ##
%
% * `Outp` [ struct ] - Output database with resampled data.
%
%
% ## Options ##
%
% * `BootstrapMethod='Efron'` [ `'Efron'` | `'Wild'` | numeric ] - Numeric
% options correspond to block sampling methods. Use a positive integer to
% specify a fixed block length, or a value strictly between zero and one to
% specify random block lengths based on a geometric distribution.
%
% * `Deviation=false` [ `true` | `false` ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `Dtrends=@auto` [ `@auto` | `true` | `false` ] - Add deterministic
% trends to measurement variables.
%
% * `Method='MonteCarlo'` [ `'Bootstrap'` | `'mOnteCarlo'` ] - Method of
% randomizing shocks and initial condition.
%
% * `Progress=false` [ `true` | `false` ] - Display progress bar in the
% command window.
%
% * `RandomInitCond=true'` [ `true` | `false` | numeric ] - Randomise
% initial condition; a number means the initial condition will be simulated
% using the specified number of extra pre-sample periods.
%
% * `StateVector='Alpha'` [ `'Alpha'` | `'X'` ] - When resampling initial
% condition, use the transformed state vector, `Alpha`, or the vector of
% original variables, `X`; this option is meant to guarantee replicability
% of results.
%
% * `SvdOnly=false` [ `true` | `false` ] - Do not attempt Cholesky and only
% use SVD to factorize the covariance matrix when resampling initial
% condition; only applies when `RandomInitCond=true`.
%
% * `Override=[ ]` [ struct | empty ] - Database with user-supplied
% time-varying paths for std deviations, correlation coefficients, or
% medians (means) of shocks.
%
%
% ## Description ##
%
% When you use wild bootstrap for resampling the initial condition, the
% results are based on an assumption that the mean of the initial condition
% is the asymptotic mean implied by the model (i.e. the steady state).
%
%
% ## References ##
%
% 1. Politis, D. N., & Romano, J. P. (1994). The stationary bootstrap.
% Journal of the American Statistical Association, 89(428), 1303-1313.
%
%
% ## Example ##
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDb = resample(this, inputDb, range, numDraws, varargin)

isintscalar = @(x) isnumeric(x) && isscalar(x) && round(x)==x;

persistent pp
if isempty(pp)
    pp = extend.InputParser('model.resample');
    addRequired(pp, 'model', @(x) isa(x, 'model') && length(x)==1 && beenSolved(x));
    addRequired(pp, 'initCondition', @(x) isempty(x) || validate.databank(x));
    addRequired(pp, 'range', @validate.properRange);
    addRequired(pp, 'numDraws', @(x) validate.roundScalar(x, 1, Inf));

    addParameter(pp, 'BootstrapMethod', 'Efron', @(x) (ischar(x) && any(strcmpi(x, {'Efron', 'Wild'}))) || validate.roundScalar(x) || validate.numericScalar(x, 0, 1));
    addParameter(pp, 'Method', 'montecarlo', @(x) isa(x, 'function_handle') || (ischar(x) && any(strcmpi(x, {'montecarlo', 'bootstrap'}))));
    addParameter(pp, 'Progress', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, {'RandomInitCond', 'RandomiseInitCond', 'RandomizeInitCond', 'Randomise', 'Randomize'}, true, @(x) isequal(x, true) || isequal(x, false) || validate.roundScalar(x, 0, Inf));
    addParameter(pp, 'SvdOnly', false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'StateVector', 'alpha', @(x) ischar(x) && any(strcmpi(x, {'alpha', 'x'})));
    addParameter(pp, {'Override', 'TimeVarying', 'Vary'}, [ ], @(x) isempty(x) || validate.databank(x));
    addParameter(pp, 'Multiply', [ ], @(x) isempty(x) || validate.databank(x));
    
    addParameter(pp, 'Deviation', false, @validate.logicalScalar);
    addParameter(pp, 'EvalTrends', logical.empty(1, 0));
end

opt = pp.parse(this, inputDb, range, numDraws, varargin{:});

if isempty(opt.EvalTrends)
    opt.EvalTrends = ~opt.Deviation;
end

% `numInit` is the number of pre-sample periods used to resample the initial
% condition if user does not wish to factorise the covariance matrix.
isWild = strcmpi(opt.BootstrapMethod, 'wild');
numInit = 0;
if isnumeric(opt.RandomInitCond)
    if strcmpi(opt.Method, 'Bootstrap') && isWild
        utils.error('model:resample', ...
            'Cannot pre-simulate initial conditions in wild bootstrap.');
    else
        numInit = opt.RandomInitCond;
        opt.RandomInitCond = false;
    end
end

if strcmpi(opt.Method, 'Bootstrap') && isempty(inputDb)
    utils.error('model:resample', ...
        'Cannot bootstrap when there are no input data.');
end

%--------------------------------------------------------------------------

range = double(range);
numPeriods = numel(range);
extendedRange = range(1)-1 : range(end);

ixd = this.Equation.Type==3;
isTrendEquations = opt.EvalTrends && any(ixd);
[ny, nxx, nb, nf, ne, ng] = sizeSolution(this.Vector);
[T, R, K, Z, H, D, U, Omg] = getSolutionMatrices(this, 1, false);
if opt.Deviation
    K(:) = 0;
    D(:) = 0;
end

% Pre-allocate output data.
hData = hdataobj(this, extendedRange, numDraws);

% Return immediately if solution is not available.
if any(isnan(T(:)))
    utils.warning('model:resample', ...
        'Solution(s) not available: #1.');
    % Convert emptpy hdataobj to tseries database.
    outputDb = hdata2tseries(hData);
    return
end

numUnitRoots = getNumOfUnitRoots(this.Variant);
numStableRoots = nb - numUnitRoots;
Ta = T(nf+1:end, :);
Ra = R(nf+1:end, :);
Ta2 = Ta(numUnitRoots+1:end, numUnitRoots+1:end);
Ra2 = Ra(numUnitRoots+1:end, :);

% Combine user-supplied stdcorr with model std/corr
optionsHere = struct('Clip', false, 'Presample', false);
overrideStdCorr = varyStdCorr(this, range, opt.Override, opt.Multiply, optionsHere);
usrStdcorrInx = ~isnan(overrideStdCorr);

% Get variation in the location of shocks
isOverrideMean = false;
if ~isempty(opt.Override) && validate.databank(opt.Override)
    overrideMean = datarequest('e', this, opt.Override, range, 1);
    if all(overrideMean(:)==0 | isnan(overrideMean(:)))
        isOverrideMean = false;
    end
end

% Get exogenous variables including ttrend.
G = datarequest('g', this, inputDb, range);

% ## Describe Distribution of Initial Conditions ##
if isequal(opt.RandomInitCond, false)
    Ealp = computeUncMean( );
elseif strcmpi(opt.Method, 'Bootstrap')
    % (1) Bootstrap.
    switch opt.BootstrapMethod
        case 'wild'
            % (1a) Wild bootstrap.
            srcAlp0 = datarequest('init', this, inputDb, range, 1);
            Ealp = computeUncMean( );
        otherwise
            % (1b) Efron or block boostrap.
            srcAlp = datarequest('alpha', this, inputDb, range, 1);
    end
else
    % (2) Monte Carlo or user-supplied sampler.
    if ~isempty(inputDb)
        % (2a) User-supplied distribution.
        [Ealp, ~, ~, Palp] = datarequest('init', this, inputDb, range, 1);
        Ex = U*Ealp;
        if isempty(Palp)
            opt.RandomInitCond = false;
        else
            if strcmpi(opt.StateVector, 'alpha')
                % (2ai) Resample `alpha` vector.
                Falp = covfun.factorise(Palp, opt.SvdOnly);
            else
                % (2aii) Resample original `x` vector.
                Px = U*Palp*U.';
                Ui = inv(U);
                Fx = covfun.factorise(Px, opt.SvdOnly);
            end
        end
    else
        % (2b) Asymptotic distribution.
        Ealp = computeUncMean( );
        Falp = zeros(nb);
        Palp = zeros(nb);
        indexUnitRoots = false(1, size(Ta2, 1)); % Ta2 is stable part of Ta (and T), no unit roots
        Palp(numUnitRoots+1:end, numUnitRoots+1:end) = ...
            covfun.acovf(Ta2, Ra2, [ ], [ ], [ ], [ ], [ ], Omg, indexUnitRoots, 0);
        if strcmpi(opt.StateVector, 'alpha')
            % (2bi) Resample the `alpha` vector.
            Falp(numUnitRoots+1:end, numUnitRoots+1:end) = ...
                covfun.factorise(Palp(numUnitRoots+1:end, numUnitRoots+1:end), opt.SvdOnly);
        else
            % (2bii) Resample the original `x` vector.
            Ex = U*Ealp;
            Px = U*Palp*U.';
            Ui = inv(U);
            Fx = covfun.factorise(Px, opt.SvdOnly);
        end
    end
end

% ## Describe Distribution of Shocks ##
if strcmpi(opt.Method, 'Bootstrap')
    % (1) Bootstrap.
    srcE = datarequest('e', this, inputDb, range, 1);
else
    % (2) Monte Carlo
    % TODO: Use `combineStdCorr` instead.
    vecStdCorr = this.Variant.StdCorr;
    vecStdCorr = permute(vecStdCorr, [2, 3, 1]);
    vecStdCorr = repmat(vecStdCorr, 1, numPeriods);
    % Combine the model object stdevs with the user-supplied stdevs.
    if any(usrStdcorrInx(:))
        vecStdCorr(usrStdcorrInx) = overrideStdCorr(usrStdcorrInx);
    end
    % Add model-object std devs for pre-sample if random initial conditions
    % are obtained by simulation.
    if numInit>0
        vecStdCorr = [vecStdCorr(:, ones(1, numInit)), vecStdCorr];
    end
    
    % Periods in which corr coeffs are all zero. In these periods, we simply
    % mutliply the standard normal shocks by std devs one by one. In all
    % other periods, we need to compute and factorize the entire cov matrix.
    indexZeroCorr = all(vecStdCorr(ne+1:end, :)==0, 1);
    if any(~indexZeroCorr)
        Pe = nan(ne, ne, numInit+numPeriods);
        Fe = nan(ne, ne, numInit+numPeriods);
        Pe(:, :, ~indexZeroCorr) = ...
            covfun.stdcorr2cov(vecStdCorr(:, ~indexZeroCorr), ne);
        Fe(:, :, ~indexZeroCorr) = covfun.factorise(Pe(:, :, ~indexZeroCorr));
    end
    
    % If user supplies sampler, sample all shocks and inital conditions at
    % once. This allows for advanced user-supplied simulation methods, e.g.
    % latin hypercube.
    if isa(opt.Method, 'function_handle')
        presampledE = opt.Method(ne*(numInit+numPeriods), numDraws);
        if opt.RandomInitCond
            presampledInitNoise = opt.Method(nb, numDraws);
        end
    end
end

% Detect shocks present in measurement and transition equations.
ixR = any(abs(R(:, 1:ne))>0, 1);
ixH = any(abs(H(:, 1:ne))>0, 1);

% Create a command-window progress bar
if opt.Progress
    progress = ProgressBar('[IrisToolbox] @Model/resample Progress');
end

% ## Simulate ##
g = [ ];
for iDraw = 1 : numDraws
    e = drawShocks( );
    if isOverrideMean
        e = e + overrideMean;
    end
    a0 = drawInitCond( );
    % Simulate transition variables.
    w = nan(nxx, numInit+numPeriods);
    w(:, 1) = T*a0 + R(:, ixR)*e(ixR, 1) + K;
    for t = 2 : numInit+numPeriods
        w(:, t) = T*w(nf+1:end, t-1) + R(:, ixR)*e(ixR, t) + K;
    end
    % Simulate measurement variables.
    y = Z*w(nf+1:end, numInit+1:end) + H(:, ixH)*e(ixH, numInit+1:end);
    if ~opt.Deviation
        y = y + D(:, ones(1, numPeriods));
    end
    % Add measurement trends to simulated data.
    if isTrendEquations
        if iDraw==1 || ~isequal(G(:, :, min(iDraw, end)), g)
            g = G(:, :, min(iDraw, end));
            W = evalTrendEquations(this, [ ], g, 1);
        end
        y = y + W;
    end
    % Store this draw.
    storeDraw( );
    % Update the progress bar.
    if opt.Progress
        update(progress, iDraw/numDraws);
    end
end

% Convert hdataobj to tseries database.
outputDb = hdata2tseries(hData);

return


    function Ealp = computeUncMean( )
        Ealp = zeros(nb, 1);
        if ~opt.Deviation
            Kalp2 = K(nf+numUnitRoots+1:end, :);
            Ealp(numUnitRoots+1:end) = (eye(numStableRoots) - Ta2) \ Kalp2;
        end
    end%


    function e = drawShocks( )
        % Resample residuals.
        if strcmpi(opt.Method, 'Bootstrap')
            if strcmpi(opt.BootstrapMethod, 'wild')
                % _Wild Bootstrap_
                % `numInit` is always zero for wild boostrap.
                draw = randn(1, numPeriods);
                % To reproduce input sample: draw = ones(1, nper);
                e = srcE.*draw(ones(1, ne), :);
            elseif isnumeric(opt.BootstrapMethod) ...
                    && opt.BootstrapMethod ~= 1
                % _Fixed or Random Block Size_
                isRandom = ~isintscalar(opt.BootstrapMethod) ;
                bs = NaN;
                if ~isRandom
                    bs = min(numPeriods, opt.BootstrapMethod) ;
                end
                draw = [ ] ;
                ii = 1 ;
                while ii<=numInit+numPeriods
                    % Sample block starting point.
                    sPoint = randi([1, numPeriods], 1) ;
                    if isRandom
                        bs = getRandBlockSize( ) ;
                    end
                    draw = [draw, sPoint:sPoint+bs-1] ; %#ok<AGROW>
                    ii = ii + bs ;
                end
                draw = draw(1:numInit+numPeriods) ;
                % Take care of references to periods beyond numPeriods.
                % Make draws circular: numPeriods+1 -> 1, etc.
                indexBeyond = draw>numPeriods ;
                while any(indexBeyond)
                    draw(indexBeyond) = draw(indexBeyond) - numPeriods ;
                    indexBeyond = draw>numPeriods ;
                end
                e = srcE(:, draw) ;
            else
                % _Standard Efron Bootstrap__
                % `draw` is uniform on [1, nper].
                draw = randi([1, numPeriods], [1, numInit+numPeriods]);
                % To reproduce input sample: draw = 0 : nper-1;
                e = srcE(:, draw);
            end
        else
            if isa(opt.Method, 'function_handle')
                % Fetch and reshape the presampled shocks.
                thisSampleE = presampledE(:, iDraw);
                thisSampleE = reshape(thisSampleE, [ne, numInit+numPeriods]);
            else
                % Draw shocks from standardised normal.
                thisSampleE = randn(ne, numInit+numPeriods);
            end
            % Scale standardised normal by the std devs.
            e = zeros(ne, numInit+numPeriods);
            e(:, indexZeroCorr) = ...
                vecStdCorr(1:ne, indexZeroCorr) .* thisSampleE(:, indexZeroCorr);
            if any(~indexZeroCorr)
                % Cross-corrs are non-zero in some periods.
                for i = find(~indexZeroCorr)
                    e(:, i) = Fe(:, :, i)*thisSampleE(:, i);
                end
            end
        end
    end%


    function a0 = drawInitCond( )
        % Randomise initial condition for stable alpha.
        if strcmpi(opt.Method, 'Bootstrap')
            % Bootstrap from empirical distribution.
            if opt.RandomInitCond
                if isWild
                    % Wild-bootstrap initial condition for alpha from given
                    % sample initial condition. This assumes that the mean is
                    % the unconditional distribution.
                    Ealp2 = Ealp(numUnitRoots+1:end);
                    a0 = [ ...
                        srcAlp0(1:numUnitRoots, 1); ...
                        Ealp2 + randn( )*(srcAlp0(numUnitRoots+1:end, 1) - Ealp2); ...
                        ];
                else
                    % Efron-bootstrap init cond for alpha from sample.
                    draw = randi([1, numPeriods], 1);
                    a0 = srcAlp(:, draw);
                end
            else
                % Fix init cond to unconditional mean.
                a0 = Ealp;
            end
        else
            % Gaussian Monte Carlo from theoretical distribution.
            if opt.RandomInitCond
                if isa(opt.Method, 'function_handle')
                    % Fetch the pre-sampled initial conditions.
                    initNoise = presampledInitNoise(:, iDraw);
                else
                    % Draw from standardised normal.
                    initNoise = randn(nb, 1);
                end
                if strcmpi(opt.StateVector, 'alpha')
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
    end%


    function storeDraw( )
        if numInit==0
            init = a0;
        else
            init = w(nf+1:end, numInit);
        end
        xf = [nan(nf, 1), w(1:nf, numInit+1:end)];
        xb = U*[init, w(nf+1:end, numInit+1:end)];
        hdataassign(hData, iDraw, ...
            { [nan(ny, 1), y], ...
            [xf;xb], ...
            [nan(ne, 1), e(:, numInit+1:end)], ...
            [ ], ...
            [nan(ng, 1), g] });
    end%


    function S = getRandBlockSize( )
        % Block size determined by geo distribution, must be smaller than numPeriods.
        p = opt.BootstrapMethod ;
        while true
            S = ceil(log(rand)/log(1-p)) ;
            if S<=numPeriods
                break
            end
        end
    end%
end%
