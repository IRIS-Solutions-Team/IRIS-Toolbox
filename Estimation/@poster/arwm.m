
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

allTheta = [];
logPosterior = [];
acceptRatio = [];
sigma = [];
finalCov = []; %#ok<NASGU>
realSmall = getrealsmall();

% Number of estimated parameters.
nPar = numel(this.ParameterNames);

% Adaptive random walk Metropolis simulator.
nAlloc = min(numDraws, opt.saveevery);
isSave = opt.saveevery<=numDraws;
if isSave
    here_prepareSave();
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

isAdaptiveScale = isfinite(gamma) && k1>0;
isAdaptiveShape = isfinite(gamma) && k2>0;
isAdaptive = isAdaptiveScale || isAdaptiveShape;

%
% Initialize proposal distribution
%
theta = reshape(this.InitParam, [], 1);
logPost = here_initializeLogPost();
j0 = this.InitCount(1); % Cumulative count of previous draws in incremental runs.
numAcceptedBefore = this.InitCount(2); % Cumulative count of previous acceptance in incremental runs.
burnin0 = this.InitCount(3); % Cumulative count of previous burn-ins.
[P, sgm] = here_initializeProposalCov();

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
    % Serial implementation
    %-----------------------

    % Propose a new theta, and evaluate log posterior.
    u = randn(nPar, 1);
    newTheta = theta + sgm*P*u;
    [newLogPost, ~, ~, ~, isWithinBounds] = mylogpost(this, newTheta); %#ok<ASGLU>

    % Generate random acceptance.
    randAccept = rand();
    here_acceptAndStore();
    j = j + 1;
end

finalCov = P*P.';

% Update the PosteriorSimulator object
this.InitLogPost = logPost;
this.InitParam = reshape(theta, 1, []);
this.InitProposalCov = finalCov;
this.InitProposalChol = P;
this.InitScale = sgm;
this.InitCount = this.InitCount + [numDrawsTotal, numAccepted, burnin];

return

    function logPost = here_initializeLogPost()
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


    function [P, sgm] = here_initializeProposalCov()
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


    function isAccepted = here_acceptAndStore()
    % Accept or reject the current proposal, and store this step

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
            here_adapt();
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
                saveH5();
                count = 0;
            end
        end

        % Update the progress bar or estimated time.
        if opt.progress
            update(progress, j/numDrawsTotal);
        end

        return

            function saveH5()
                h5write( opt.SaveAs, ...
                         '/theta', allTheta, [1, saveCount+1], size(allTheta) );
                h5write( opt.SaveAs, ...
                         '/logPost', logPosterior, [1, saveCount+1], size(logPosterior) );
                saveCount = saveCount + size(allTheta, 2);
                n = numDrawsTotal - j;
                if n==0
                    allTheta = [];
                    logPosterior = [];
                    acceptRatio = [];
                    sigma = [];
                elseif n<nAlloc
                    allTheta = allTheta(:, 1:n);
                    logPosterior = logPosterior(1:n);
                    acceptRatio = acceptRatio(1:n);
                    if isAdaptiveScale
                        sigma = sigma(:, 1:n);
                    end
                end
            end%


            function here_adapt()
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


    function here_prepareSave()
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
end%

