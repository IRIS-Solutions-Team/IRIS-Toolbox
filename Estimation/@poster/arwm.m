
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team & Bojan Bejanov & Troy Matheson

function ...
    [allTheta, logPosterior, acceptRatio, this, sigma, finalCov] ...
    = arwm(this, numDraws, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser('poster.arwm');
    addParameter(ip, {'AdaptScale'}, 1, @(x) validate.numericScalar(x, 0, Inf));
    addParameter(ip, {'AdaptShape', 'AdaptProposalCov'}, 0.5, @(x) validate.numericScalar(x, 0, Inf));
    addParameter(ip, 'burnin', 0.10, @(x) validate.numericScalar(x, 0, 1) || validate.roundScalar(x, 1, Inf));
    addParameter(ip, 'gamma', 0.8, @(x) validate.numericScalar(x, 0.5, 1) || isequaln(x, NaN));
    addParameter(ip, 'initscale', @auto, @(x) isequal(x, @auto) || validate.numericScalar(x, 0+eps));
    addParameter(ip, 'lastadapt', Inf, @(x) validate.nummericScalar(x, 0, 1) || validate.roundScalar(x, 1, Inf));
    addParameter(ip, 'progress', false, @validate.logicalScalar);
    addParameter(ip, 'saveevery', Inf, @(x) validate.roundScalar(x, 1, Inf));
    addParameter(ip, 'SaveAs', '', @(x) ischar(x) || isstring(x));
    addParameter(ip, 'targetar', 0.234, @(x) validate.numericScalar(x, 0+eps, 0.5));
    addParameter(ip, {'nstep', 'nsteps'}, 1, @(x) validate.roundScalar(x, 1, Inf));
end
parse(ip, varargin{:});
opt = ip.Results;

opt.SaveAs = char(opt.SaveAs);

allTheta = [ ];
logPosterior = [ ];
acceptRatio = [ ];
sigma = [ ];
finalCov = [ ]; %#ok<NASGU>
realSmall = getrealsmall( );

% Number of estimated parameters.
nPar = numel(this.ParameterNames);

% Adaptive random walk Metropolis simulator.
nAlloc = min(numDraws, opt.saveevery);
isSave = opt.saveevery<=numDraws;
if isSave
    here_prepareSave( );
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
k1 = opt.AdaptScale;
k2 = opt.AdaptShape;
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
    progress = ProgressBar('[IrisToolbox] @poster/arwm Progress');
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
            hereAdapt( );
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
            h5write( opt.SaveAs, ...
                     '/theta', allTheta, [1, saveCount+1], size(allTheta) );
            h5write( opt.SaveAs, ...
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


        function hereAdapt( )
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


    function here_prepareSave( )
        if strlength(opt.SaveAs)==0
            utils.error('poster', ...
                'The option SaveAs must be a valid file name.');
        end
        % Create an HDF5
        h5create(opt.SaveAs, '/theta', [nPar, numDraws], 'fillValue', NaN);
        h5create(opt.SaveAs, '/logPost', [1, numDraws], 'fillValue', NaN);
        h5writeatt(opt.SaveAs, '/', 'paramList', char(join(this.ParameterNames, " ")));
        h5writeatt(opt.SaveAs, '/', 'numDraws', numDraws);
        h5writeatt(opt.SaveAs, '/', 'saveEvery', opt.saveevery');
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
        %  Copyright (c) 2012-2022 Boyan Bejanov and the IRIS Solutions Team
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
