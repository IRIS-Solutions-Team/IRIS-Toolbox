function [allTheta, logPosterior, acceptRatio, this, sigma, finalCov] = arwm(this, numDraws, varargin)%
% arwm  Adaptive random-walk Metropolis posterior simulator.
%
% __Syntax__
%
%     [Theta, LogPost, AcceptRatio, Poster] = arwm(Pos, NumOfDraws, ...)
%     [Theta, LogPost, AcceptRatio, Poster, Sigma, FinalCov] = arwm(Pos, NumOfDraws, ...)
%
%
% __Input Arguments__
%
% * `Pos` [ poster ] - Initialised posterior simulator object.
%
% * `numDraws` [ numeric ] - Length of the chain not including burn-in.
%
%
% __Output Arguments__
%
% * `Theta` [ numeric ] - MCMC chain with individual parameters in rows.
%
% * `LogPost` [ numeric ] - Vector of log posterior density (up to a
% constant) in each draw.
%
% * `AcceptRatio` [ numeric ] - Vector of cumulative acceptance ratios.
%
% * `Poster` [ poster ] - Posterior simulator object with its properties
% updated so to capture the final state of the simulation.
%
% * `Sigma` [ numeric ] - Vector of proposal scale factors in each draw.
%
% * `FinalCov` [ numeric ] - Final proposal covariance matrix; the final
% covariance matrix of the random walk step is Scale(end)^2*FinalCov.
%
%
% __Options__
%
% * `AdaptProposalCov=0.5` [ numeric ] - Speed of adaptation of the
% Cholesky factor of the proposal covariance matrix towards the target
% acceptanace ratio, `TargetAR`; zero means no adaptation.
%
% * `AdaptScale=1` [ numeric ] - Speed of adaptation of the scale factor to
% deviations of acceptance ratios from the target ratio, `targetAR`.
%
% * `BurnIn=0.10` [ numeric ] - Number of burn-in draws entered
% either as a percentage of total draws (between 0 and 1) or directly as a
% number (integer greater that one). Burn-in draws will be added to the
% requested number of draws `NumOfDraws` and discarded after the posterior
% simulation.
%
% * `FirstPrefetch=Inf` [ numeric | `Inf` ] - First draw where
% parallelized pre-fetching will be used; `Inf` means no pre-fetching.
%
% * `Gamma=0.8` [ numeric ] - The rate of decay at which the scale and/or
% the proposal covariance will be adapted with each new draw.
%
% * `InitScale=1/3` [ numeric ] - Initial scale factor by which the initial
% proposal covariance will be multiplied; the initial value will be adapted
% to achieve the target acceptance ratio.
%
% * `LastAdapt=Inf` [ numeric | `Inf` ] - Last point at which the proposal
% covariance will be adapted; `Inf` means adaptation will continue until
% the last draw. Can also be entered as a percentage of total draws (a
% number strictly between 0 and 1). 
%
% * `NStep=1` [ numeric ] - Number of pre-fetched steps computed in
% parallel; only works with `FirstPrefetch=` smaller than `NumOfDraws`.
%
% * `Progress=false` [ `true` | `false` ] - Display a progress bar in the
% command window.
%
% * `SaveAs=''` [ char ] - File name where results will be saved when the
% option `SaveEvery=` is used.
%
% * `SaveEvery=Inf` [ numeric | `Inf` ] - Every N draws will be saved to an
% HDF5 file, and removed from workspace immediately; no values will be
% returned in the output arguments `Theta`, `LogPosterior`, `AcceptRatio`,
% `Sigma`; the option `SaveAs=` must be used to specify the file name;
% `Inf` means a normal run with no saving.
%
% * `TargetAR=0.234` [ numeric ] - Target acceptance ratio.
%
%
% __Description__
%
% The function `poster/arwm` returns the simulated chain of parameters and
% the corresponding value of the log posterior density. To obtain simulated
% sample statistics for each parameter (such as posterior mean, median, 
% percentiles, etc.) use the function [`poster/stats`](poster/stats) to
% process the simulated chain and calculate the statistics.
%
% The properties of the posterior object returned as the 4th output
% argument are updated so that they capture the final state of the
% posterior simulations. This can be used to initialize a next simulation
% at the point where the previous ended.
%
%
% _Parallelised ARWM_
%
% Set `'nStep='` greater than `1`, and `'firstPrefetch='` smaller than
% `numDraws` to start a pre-fetching parallelised algorithm (pre-fetched will
% be all draws starting from `'firstPrefetch='`); to that end, a pool of
% parallel workers (using e.g. `matlabpool` from the Parallel Computing
% Toolbox) must be opened before calling `arwm`.
%
% With pre-fetching, all possible paths `'nStep='` steps ahead (i.e. all
% possible combinations of reject/accept) are pre-evaluated in parallel, 
% and then the resulting path is selected. Adapation then occurs only every
% `'nStep='` steps, and hence the results will always somewhat differ from
% a serial run. Identical results can be obtained by turning down
% adaptation before pre-fetching starts, i.e. by setting `'lastAdapt='`
% smaller than `'firstPrefetch='` (and, obviously, by re-setting the random
% number generator).
% 
%
% __References__
%
% * Brockwell, A.E., 2005. "Parallel Markov Chain Monte Carlo Simulation
% by Pre-Fetching, " CMU Statistics Dept. Tech. Report 802.
%
% * Strid, I., 2009. "Efficient parallelisation of Metropolis-Hastings
% algorithms using a prefetching approach, " SSE/EFI Working Paper Series in
% Economics and Finance No. 706.
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team & Bojan Bejanov & Troy Matheson

% Validate required inputs.
pp = inputParser( );
pp.addRequired('Pos', @(x) isa(x, 'poster'));
pp.addRequired('numDraws', @isnumericscalar);
pp.parse(this, numDraws);

% Parse options.
opt = passvalopt('poster.arwm', varargin{:});

%--------------------------------------------------------------------------

allTheta = [ ];
logPosterior = [ ];
acceptRatio = [ ];
sigma = [ ];
finalCov = [ ]; %#ok<NASGU>
realSmall = getrealsmall( );

% Number of estimated parameters.
nPar = length(this.ParamList);

% Adaptive random walk Metropolis simulator.
nAlloc = min(numDraws, opt.saveevery);
isSave = opt.saveevery <= numDraws;
if isSave
    prepareSave( );
end

if opt.burnin<1
    % Burn-in is a percentage.
    burnin = round(opt.burnin*numDraws);
else
    % Burn-in is the number of draws.
    burnin = opt.burnin;
end

if opt.lastadapt<1
    % lastadapt is a percentage.
    opt.lastadapt = round(opt.lastadapt*numDraws) ;
end

numDrawsTotal = numDraws + burnin;

% Adaptation parameters
gamma = opt.gamma;
k1 = opt.adaptscale;
k2 = opt.adaptproposalcov;
targetAr = opt.targetar;

doChkParallel( );

isAdaptiveScale = isfinite(gamma) && k1>0;
isAdaptiveShape = isfinite(gamma) && k2>0;
isAdaptive = isAdaptiveScale || isAdaptiveShape;

%
% Initialize proposal distribution
%
theta = reshape(this.InitParam, [ ], 1);
logPost = hereInitializeLogPost( );
j0 = this.InitCount(1); % Cumulative count of previous draws in incremental runs.
numAcceptedBefore = this.InitCount(2); % Cumulative count of previous acceptance in incremental runs.
burnin0 = this.InitCount(3); % Cumulative count of previous burn-ins.
[P, sgm] = hereInitializeProposalCov( );

% Pre-allocate output data
allTheta = zeros(nPar, nAlloc);
logPosterior = zeros(1, nAlloc);
acceptRatio = zeros(1, nAlloc);
if isAdaptiveScale
    sigma = zeros(1, nAlloc);
else
    sigma = sgm;
end

if opt.progress
    progress = ProgressBar('IRIS poster.arwm progress');
end

% __Main Loop__

if opt.nstep>1
    % Minimize communication overhead:
    ThisPf = WorkerObjWrapper( this ) ;
end

j = 1;
numAccepted = 0;
count = 0;
saveCount = 0;
while j<=numDrawsTotal
    if j>=opt.firstPrefetch
        nStep = min(opt.nstep, 1+numDrawsTotal-j);
        nPath = 2^nStep;
    else
        nStep = 1;
        nPath = 1;
    end
    
    if nStep==1
        
        % Serial implementation
        %-----------------------
        
        % Propose a new theta, and evaluate log posterior.
        u = randn(nPar, 1);
        newTheta = theta + sgm*P*u;
        [newLogPost, ~, ~, ~, isWithinBounds] = mylogpost(this, newTheta); %#ok<ASGLU>
        
        % Generate random acceptance.
        randAccept = rand( );
        acceptAndStore( );
        j = j + 1;
        
    else
        
        % Parallel implementation
        %-------------------------
        
        % Number of steps, number of parallel paths.
                
        % Propose new thetas, evaluate log posteriors for all of them in parallel, 
        % and pre-generate random acceptance.
        [thetaPf, logPostPf, randAcceptPrefetched, uPf] = prefetch( );
        
        % Find path through lattice prefetch; `pos0` is a zero-based position
        % beween `0` and `2^nsteps`.
        pos0 = 0;
        
        for iStep = 1 : nStep
            % New proposals.
            newPos0 = bitset(pos0, iStep);
            newTheta = thetaPf(:, 1+newPos0);
            newLogPost = logPostPf(1+newPos0);
            isWithinBounds = true; %#ok<NASGU>
            randAccept = randAcceptPrefetched(iStep);
            u = uPf(:, iStep);
            
            isAccepted = acceptAndStore( );
            if isAccepted
                pos0 = newPos0;
            end
            j = j + 1;
        end
    end
end

finalCov = P*P.';

% Update the PosteriorSimulator object
this.InitLogPost = logPost;
this.InitParam = reshape(theta, 1, [ ]);
this.InitProposalCov = finalCov;
this.InitProposalChol = P;
this.InitScale = sgm;
this.InitCount = this.InitCount + [numDrawsTotal, numAccepted, burnin];

return

    function logPost = hereInitializeLogPost( )
        % Evaluate initial log posterior density.
        logPost = mylogpost(this, theta);
        if ~isempty(this.InitLogPost) && isfinite(this.InitLogPost) ...
           && maxabs(logPost-this.InitLogPost)>realSmall
            thisWarning = { 'PosteriorSimulator:InitLogPostDiscrepancy'
                            'Log posterior density at .InitParam differs from '
                            '.InitLogPost by a margin larger than rounding error' };
            throw(exception.Base(thisWarning, 'warning'));
        end
    end%


    function [P, sgm] = hereInitializeProposalCov( )
        % Initial proposal cov matrix and its Cholesky factor
        if isequal(opt.initscale, @auto)
            sgm = this.InitScale;
        else
            sgm = opt.initscale;
        end
        if ~isempty(this.InitProposalChol)
            P = this.InitProposalChol;
            if ~isempty(this.InitProposalCov) ...
               && maxabs(P*P.'-this.InitProposalCov)>realSmall
                thisWarning = { 'PosteriorSimulator:InitProposalCovDiscrepancy'
                                'Initial proposal covariance matrix and its Cholesky factor'
                                'result in a discrepanyc larger than rounding error' };
                throw(exception.Base(thisWarning, 'warning'));
            end
        else
            P = transpose(chol(this.InitProposalCov));
        end
    end% 

    
    function isAccepted = acceptAndStore( )
        % acceptAndStore  Accept or reject the current proposal, and store this
        % step.
        
        % Prob of new proposal being accepted; `newLogPost` can be `-Inf`, in which
        % case `alpha` is zero. If both `logPost` and `newLogPost` are `-Inf` the
        % inner max function returns `0` and the new proposal is never accepted.
        alpha = min(1, max(0, exp(newLogPost-logPost)));
        
        % Decide if we accept the new theta.
        isAccepted = randAccept<alpha;

        if isAccepted
            logPost = newLogPost;
            theta = newTheta;
        end
        
        isAdaptive = isAdaptive && j-burnin<=opt.lastadapt;
        
        % Adapt the scale and/or proposal covariance.
        if isAdaptive
            adapt( );
        end
        
        % Add the j-th theta to the chain unless still burning in
        if j>burnin
            count = count + 1;
            numAccepted = numAccepted + nnz(isAccepted);
            % Paremeter draws.
            allTheta(:, count) = theta;
            % Value of log posterior at the current draw.
            logPosterior(count) = logPost;
            % Acceptance ratio so far.
            acceptRatio(count) = (numAcceptedBefore+numAccepted) / (j-burnin+j0-burnin0);
            % Adaptive scale factor.
            if isAdaptiveScale
                sigma(count) = sgm;
            end
            % Save and reset.
            if count==opt.saveevery || (isSave && j==numDrawsTotal)
                saveH5( );
                count = 0;
            end
        end
        
        % Update the progress bar or estimated time.
        if opt.progress
            update(progress, j/numDrawsTotal);
        end
        
        return

        
        function saveH5( )
            h5write( opt.saveas, ...
                     '/theta', allTheta, [1, saveCount+1], size(allTheta) );
            h5write( opt.saveas, ...
                     '/logPost', logPosterior, [1, saveCount+1], size(logPosterior) );
            saveCount = saveCount + size(allTheta, 2);
            n = numDrawsTotal - j;
            if n==0
                allTheta = [ ];
                logPosterior = [ ];
                acceptRatio = [ ];
                sigma = [ ];
            elseif n<nAlloc
                allTheta = allTheta(:, 1:n);
                logPosterior = logPosterior(1:n);
                acceptRatio = acceptRatio(1:n);
                if isAdaptiveScale
                    sigma = sigma(:, 1:n);
                end
            end
        end%
        
        
        function adapt( )
            nu = (j+j0)^(-gamma);
            phi = nu*(alpha - targetAr);
            if isAdaptiveScale
                phi1 = k1*phi;
                sgm = exp(log(sgm) + phi1);
            end
            if isAdaptiveShape
                phi2 = k2*phi;
                unorm2 = u.'*u;
                z = sqrt(phi2/unorm2)*u;
                P = cholupdate(P.', P*z).';
            end
        end%
    end%

    
    function prepareSave( )
        if isempty(opt.saveas)
            utils.error('poster', ...
                'The option ''saveas='' must be a valid file name.');
        end
        % Create an HDF5.
        h5create(opt.saveas, '/theta', [nPar, numDraws], 'fillValue', NaN);
        h5create(opt.saveas, '/logPost', [1, numDraws], 'fillValue', NaN);
        h5writeatt(opt.saveas, '/', ...
            'paramList', sprintf('%s ', this.ParamList{:}));
        h5writeatt(opt.saveas, '/', 'nDraw', numDraws);
        h5writeatt(opt.saveas, '/', 'saveEvery', opt.saveevery');
    end%

    
    function [thetaPf, LogPostPf, RandAccPf, uPf] = prefetch( )
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  The wisdom behind the indexing in the prefetching array
        %
        %  starting from point 'curr_pt' we want to make n steps.  At each step we
        %  generate a random walk point from the current one and either accept the
        %  new point or reject the new point and keep the current one.  We assign
        %  to 'accept' the bit 1 and to 'reject' the bit 0.  The total number of
        %  possible points at the end of n steps is 2^n.  Each possible path is
        %  uniquely described by the ordered bits in the binary representation of a
        %  number between 0 and 2^n-1.  The right-most (least significant) bit
        %  represents the outcome at the first step, and so on moving to the left
        %  each step, until the left-most (most significant) bit represents the
        %  outcome at the n-th step.
        %
        %  E.g. for n=2 we have
        %                    00
        %                /       \
        %              00         01
        %            /    \     /    \
        %          00     10   01    11
        %          (0)    (2)  (1)   (3)    <-- index in the array minus one
        %
        %  A point with some intdex, r, was generated on the step, k, equal to the
        %  position of the left-most 1 bit in the binary representation of r.
        %  (Positions are counted from right to left)
        %  Points generated from this one will have indices derived from r by
        %  setting a bit further to the left to 1, up to and including bit in
        %  position n.
        %
        %  NOTE: this binary indexing gives values from 0 to 2^n-1.  Since in
        %  MATLAB indices are unit-based, we add one to get a valid MATLAB index.
        %
        %  Copyright (c) 2012-2019 Boyan Bejanov and the IRIS Solutions Team
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Pre-generate random increments. The increments are path-independent so
        % that we can reproduce the results of a no-prefetch algorithm (turning off
        % adaptation): in each step, a single unique random vector is used
        % independent of the history.
        %
        % Moreover, pre-generate a vector of random acceptance in the same sequence
        % of steps as in serial implementation.
        X = nan(nPar, nStep);
        RandAccPf = nan(1, nStep);
        uPf = nan(nPar, nStep);
        for iiStep = 1 : nStep
            uPf(:, iiStep) = randn(nPar, 1);
            X(:, iiStep) = sgm*P*uPf(:, iiStep);
            RandAccPf(iiStep) = rand( );
        end
        
        % Pre-allocate path-dependent end-points, nPath = 2^nStep.
        thetaPf = nan(nPar, nPath);
        
        % Generate all possible paths.
        generatePaths(theta, 1, 0);
        
        % Evaluate log posterior for each path.
        LogPostPf = nan(nPath, 1);
        LogPostPf(1) = logPost;
        parfor iPath = 2 : nPath
            LogPostPf(iPath) = mylogpost(ThisPf.Value, thetaPf(:, iPath)); %#ok<PFBNS>
        end

        return
        
        function generatePaths(theta0, Step, PathSoFar)
            % Proposal rejected.
            thetaRej = theta0;
            pathRej = PathSoFar;
            % Proposal accepted.
            thetaAcc = theta0 + X(:, Step);
            pathAcc = bitset(PathSoFar, Step);
            if Step<nStep
                % Fork the paths.
                generatePaths(thetaRej, Step+1, pathRej);
                generatePaths(thetaAcc, Step+1, pathAcc);
            else
                % Store the end-point.
                thetaPf(:, 1+pathRej) = thetaRej;
                thetaPf(:, 1+pathAcc) = thetaAcc;
            end
        end%
    end%


    function doChkParallel( )
        if opt.firstPrefetch<numDrawsTotal && opt.nstep>1
            isPCT = license('test', 'distrib_computing_toolbox');
            if isPCT
                nWorkers = matlabpool('size');
                if nWorkers <= 1
                    utils.warning('poster', ...
                        'Prefetching without parallelism is pointless.');
                elseif nWorkers>2^opt.nstep-1
                    utils.warning('poster', ...
                        'Some workers will be idle, consider increasing the number of prefetch steps.');
                elseif opt.nstep<log2(opt.nstep*(nWorkers+1))
                    utils.warning('poster', ...
                        'Sequential version will be faster. Consider decreasing the number of prefetch steps.');
                end
            else
                utils.warning('poster', ...
                    'Prefetching without parallelism is pointless.');
            end
        end
    end % doChkParallel( )
end
