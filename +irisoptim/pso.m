function [X1,fval,exitflag,output,population,scores,LAMBDA,state] = ...
    pso(varargin)
% pso  Particle swarm stochastic optimization algorithm.
%
%
% Syntax
% =======
%
% [X1,F] = irisoptim.pso(Fun,LB,UB)
% [X1,F] = irisoptim.pso(Fun,X0,LB,UB)
%
%
% Input arguments
% ================
%
% * `X0` [ numeric ] - Initial values.
%
% * `LB` [ numeric ] - Lower bounds.
%
% * `UB` [ numeric ] - Upper bounds.
%
%
% Output arguments
% =================
%
% * `X1` [ numeric ] - Optimized vector.
%
% * `F` [ numeric ] - Final objective function value.
%
%
% Options
% ========
%
% * `'cognitiveAttraction='` [ numeric | *`0.5`* ] -  Scalar between `0`
% and `1` to control the relative attraction to the best location a
% particle can remember.
%
% * `'constrBoundary='` [ `absorb` | *`reflect`* | `soft` ] - Controls the
% way imposed constraints are handled when violated.
%
%     * `'soft'`: Particles are allowed to travel outside the bounds but
%     get bad fitness function (likelihood) values when they do;
%
%     * `'reflect'`: Particle velocity is changed such that when the
%     particle encounters the bound its velocity is changed to effectively
%     make it bounce off of the boundary;
%
%     * `'absorb'`: Particles hit the bound and stay at the bound until
%     attracted elsewhere because its velocity is set to zero.
%
% * `'display='` [ `'off'` | `'final'` | *`'iter'`* ] - Level of display in
% order of increasing verbosity; `'iter'` will only produce output at most
% `'updateInterval='` seconds.
%
% * `'fitnessLimit='` [ numeric | *`-Inf`* ] - Algorithm will terminate
% when a function value this low is encountered.
%
% * `'maxIter='` [ numeric | *`1000`* ] - Positive integer describing
% the maximum length of swarm evolution.
%
% * `'hybrid='` [ `true` | *`false`* | `'fmincon'` | `'fminunc'` | cell ]
% - Run a second stage optimization after PSO:
%
%     * `false`: No second stage optimization, run the particle swarm only.
%
%     * `true`: After PSO, run either `fminunc` or `fmincon`, the
%     Optimization Toolbox routines, depending on the presence or absence
%     of lower and upper bounds on estimated parameters.
%
%     * `'fminunc'`, `'fmincon'`: After PSO, run the specified Optimization
%     Toolbox routine.
%
%     * cell: A cell array in which the first argument specifies the
%     function as previously and the second argument contains the options
%     structure for that function; for instance
%     `{@fmincon,optimset('Display','iter')}`.
%
% * `'includeInitialValue='` [ `true` | *`false`* ] - Include the initial
% vector of parameters in the initial population.
%
% * `'initialPopulation=`' [ numeric | *empty* ] - An NPar-by-NPop array
% containing the initial distribution of particles, where NPar is the
% number of estimated parameters, and NPop is the size of population. If
% empty, a population will be created containing the initial parameter
% vector and the rest of the particles will be randomly generated according
% to `'popInitRange='`. Use the option `'includeInitialValue=' false` oo
% exclude the initial value from the initial population so that the entire
% population is randomly generated.
%
% * `'socialAttraction='` [ numeric | *`1.25`* ] - Positive scalar to
% control the relative attraction of each particle to the best location
% they have heard about from other particles.
%
% * `'plotFcns='` [ cell | *empty* ] - Cell array of function handles to
% functions which accept `(options,state,flag)` values as input arguments.
% The only built-in general-purpose plotting function is
% `@irisoptim.scoreDiversity`.
%
% * `'populationSize='` [ numeric | *`40`* ] - Positive integer which
% determines the number of particles in the swarm.
%
% * `'popInitRange='` [ numeric | *empty* ] - A 2-by-NPar array which sets
% the range over which the initial population will be distributed, where
% NPar is the number of estimated parameters, or a 2-by-1 array with the
% range for all parameters. If empty and `'PopInitRange='` is not set, the
% upper and lower bounds will be used if both are finite. If either of the
% bounds are infinite, the range will be `[0;1]`.
%
% * `'stall='` [ numeric | *`100`* ] - Maximum number of swarm
% iterations which result in no improvement in the fitness function
% (likelihood) value before the algorithm terminates.
%
% * `'timeLimit='` [ numeric | *`Inf`* ] - Maximum running time in seconds.
%
% * `'tolCon='` [ numeric | *`1e-6`* ] - Largest tolerated constraint
% violation.
%
% * `'tolFun='` [ numeric | *`1e-6`* ] - Function tolerance; when the
% change in the best fitness function value (likelihood) improvement per
% generation falls below this value the algorithm will terminate.
%
% * `'velocityLimit='` [ numeric | *`Inf`* ] - Positive scalar to bound
% particle intertia from above.
%
% * `'updateInterval='` [ numeric | *0* ] - Minimum length of time in
% seconds which must pass before new command window output will be
% produced.
%
% * `'parallel='` [ `true` | *`false`* ] - Use a `parfor` loop which
% requires you already have a `matlabpool` open. Overhead is slightly
% higher for constrained problems than unconstrained problems.
%
%
% References
% =============
%
% 1. Kennedy, J.; Eberhart, R. C.; and Shi, Y. H. (2001). Swarm
% Intelligence. Academic Press.
%
% 2. Mikki, S. M.; and Kishk, A. A. (2008). Particle Swarm Optimization:
% A Physics-Based Approach. Morgan & Claypool.
%
% 3. Perez, R. E.; and Behdinan, K. (2007) "Particle swarm approach for
% structural design optimization." Computers and Structures,
% Vol. 85:1579-88, 2007.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team and Sam Chen.

% handle case where irisoptim.pso( ) is not being called by shared.Estimation.estimate( )

optStartIndex = nargin ;
for ii = 1:nargin
    if isa(varargin{ii},'char')
        optStartIndex = ii-1 ;
        break
    end
end

tobj = varargin{1} ;
if optStartIndex==3
    X0 = [ ] ;
    LB = varargin{2} ;
    UB = varargin{3} ;
    varargin(1:3) = [ ] ;
elseif optStartIndex==4
    X0 = varargin{2} ;
    LB = varargin{3} ;
    UB = varargin{4} ;
    varargin(1:4) = [ ] ;
end

[options] = passvalopt('irisoptim.pso',varargin{:});

if ~isempty(X0)
    nvars=numel(X0);
    [s1,s2]=size(X0);
    if s1>s2, X0=X0'; end %make X0 a row vec
elseif ~isempty(LB)
    nvars = numel(LB) ;
end

switch options.Display
    case 'off'
        options.Verbosity=0;
    case 'final'
        options.Verbosity=2;
    otherwise
        % default
        options.Verbosity=3;
end

constr=false;
if ~exist('LB','var'), LB = [ ] ; else constr=true; end
if ~exist('UB','var'), UB = [ ] ; else constr=true; end

LB = reshape(LB,[ ],numel(LB)) ;
UB = reshape(UB,[ ],numel(UB)) ;

if isempty(options.PopInitRange)
    options.InitialPopulationUsesBounds=true;
    options.PopInitRange=[0;1];
end
matlab_optimtbx=license('test','optimization_toolbox');
if matlab_optimtbx && isequal(options.HybridFcn,true)
    % Do not automatically adjust function tolerance in hybrid runs.
    % options.TolFun=1e-2;
    options=xxHybridDefaults(options,LB,UB);
else
    %either optimization toolbox cannot be found or options.HybridFcn is
    %already specified
end

% Check for swarm stability
if options.SocialAttraction + options.CognitiveAttraction >= 4
    fprintf(1,'Warning: Swarm is unstable and may not converge since the sum of the cognitive and social attraction parameters is greater than or equal to 4. Suggest adjusting options.CognitiveAttraction and/or options.SocialAttraction.\n');
end

% Is options.PopInitRange reconcilable with LB and UB constraints?
% Resize PopInitRange in case it was given as one range for all dimensions
if size(options.PopInitRange,2) == 1 && nvars > 1
    options.PopInitRange = repmat(options.PopInitRange,1,nvars) ;
end

% use compact space from UB/LB if available
if options.InitialPopulationUsesBounds
    if options.Verbosity>0
        fprintf(1,'No initial population range given, using finite bounds where available.');
    end
    if ~isempty(LB) && ~isempty(UB)
        for ii=1:nvars
            if isfinite(LB(ii)) && isfinite(UB(ii))
                options.PopInitRange(1,ii)=LB(ii);
                options.PopInitRange(2,ii)=UB(ii);
            end
        end
    end
end

% Check initial population with respect to bound constraints
% Is this really desirable? Maybe there are some situations where the user
% specifically does not want a uniform inital population covering all of
% LB and UB?
if ~isempty(LB) || ~isempty(UB)
    options.LinearConstr.type = 'boundconstraints' ;
    if isempty(LB), LB = -inf*ones(1,nvars) ; end
    if isempty(UB), UB =  inf*ones(1,nvars) ; end
    options.PopInitRange = ...
        psocheckpopulationinitrange(options.PopInitRange,LB,UB) ;
end

% Check validity of VelocityLimit
if all(~isfinite(options.VelocityLimit))
    options.VelocityLimit = [ ] ;
elseif isscalar(options.VelocityLimit)
    options.VelocityLimit = repmat(options.VelocityLimit,1,nvars) ;
elseif ~isempty(length(options.VelocityLimit)) && ...
        ~isequal(length(options.VelocityLimit),nvars)
    error('options.VelocityLimit must be either a positive scalar or a vector of size 1xnvars.')
end % if isscalar
options.VelocityLimit = abs(options.VelocityLimit) ;

% Generate swarm initial state
if numel(options.InitialPopulation)==nvars || options.IncludeInitialValue
    if options.IncludeInitialValue
        options.InitialPopulation=[ ];
    else
        X0=options.InitialPopulation;
        options.InitialPopulation=[ ];
    end
    state = psocreationuniform(options,nvars) ;
    state.Population(1,:)=X0; %allow mix of random population and known reasonable starting value
else
    state = psocreationuniform(options,nvars) ;
end

% Check constraint type
if isa(options.ConstrBoundary,'function_handle')
    boundsCheckFn = options.ConstrBoundary ;
elseif strcmpi(options.ConstrBoundary,'soft')
    boundsCheckFn = @boundsSoft ;
elseif strcmpi(options.ConstrBoundary,'penalize')
    boundsCheckFn = @boundsPenalize ;
    state.Penalty = zeros(options.PopulationSize,1) ;
    state.PreviouslyFeasible = true(options.PopulationSize,1) ;
elseif strcmpi(options.ConstrBoundary,'reflect')
    boundsCheckFn = @boundsReflect ;
elseif strcmpi(options.ConstrBoundary,'absorb')
    boundsCheckFn = @boundsAbsorb ;
end

n = options.PopulationSize ;

% Change suggested by "Ben" from MATLAB Central.
if ~isempty(options.PlotFcns)
    hFig = findobj('Tag', 'PSO Plots', 'Type', 'figure');
    if isempty(hFig)
        state.hfigure = figure(...
            'NumberTitle', 'off', ...
            'Name', 'Particle Swarm Optimization', ...
            'NextPlot', 'replacechildren', ...
            'Tag', 'PSO Plots' );
    else
        state.hfigure = hFig;
        set(0, 'CurrentFigure', state.hfigure);
        clf
    end
    clear hFig
end % if ~isempty

if options.Verbosity > 0, fprintf('\nSwarming...\n\n'), end
exitflag = 0 ; % Default exitflag, for max iterations reached.
flag = 'init' ;

state.tobj = tobj ;
state.LastImprovement = 1 ;
state.ParticleInertia = 0.9 ; % Initial inertia
state.OutOfBounds = false(options.PopulationSize,1) ;

% Iterate swarm
averagetime = 0 ;
t0=tic;
if options.Verbosity>0
    fprintf(1,'Number of variables: %g\n',nvars);
    fprintf(1,'Population size: %g \n',n);
    if constr, fprintf(1,'Boundary method: %s\n',options.ConstrBoundary); end
    fprintf(1,'\n');
end
if options.Verbosity > 2
    t2=uint64(0);
end
if options.UseParallel
    objfuncPf = WorkerObjWrapper( @(x) tobj(x) ) ;
end
if options.UseParallel && not(constr)
    % use more efficient parallell implementation, don't check bounds, no
    % extra temporary variables, no plotting availability
    
    statePopulation=state.Population;
    for k = 1:options.Generations
        stateScore = inf*ones(n,1) ; % Reset fitness vector
        state.Generation = k ;
        
        % Evaluate fitness
        parfor i = 1:n
            stateScore(i) = feval(objfuncPf.Value,statePopulation(i,:));
        end
        
        % Update the local bests
        betterindex = stateScore < state.fLocalBests ;
        state.fLocalBests(betterindex) = stateScore(betterindex) ;
        state.xLocalBests(betterindex,:) = ...
            statePopulation(betterindex,:) ;
        
        % Update the global best and its fitness, then check for termination
        [minfitness, minfitnessindex] = min(stateScore) ;
        
        if minfitness < state.fGlobalBest
            state.fGlobalBest(k) = minfitness ;
            state.xGlobalBest = statePopulation(minfitnessindex,:) ;
            state.LastImprovement = k ;
            imprvchk = k > options.StallGenLimit && ...
                (state.fGlobalBest(k - options.StallGenLimit) - ...
                state.fGlobalBest(k)) / (k - options.StallGenLimit) < ...
                options.TolFun ;
            if imprvchk
                exitflag = 1 ;
                flag = 'done' ;
            elseif state.fGlobalBest(k) < options.FitnessLimit
                exitflag = 2 ;
                flag = 'done' ;
            end % if k
        elseif k > 1 % No improvement from last iteration
            state.fGlobalBest(k) = state.fGlobalBest(k-1) ;
        end % if minfitness
        
        
        stall = k - state.LastImprovement ;
        stallchk = stall >= options.StallGenLimit ;
        if stallchk
            % No improvement for StallGenLimit generations
            exitflag = 3 ;
            flag = 'done' ;
        end
        
        if options.Verbosity>2 && toc(t2)>options.UpdateInterval
            t2=tic;
            fprintf(1,'[%g] min(f) = %g, stall = %g\n',k,state.fGlobalBest(k),stall) ;
        end
        
        t1=toc(t0);
        if t1 + averagetime > options.TimeLimit
            exitflag = 5 ;
            flag = 'done' ;
        end
        
        % Update flags, state and plots before updating positions
        if k == 2, flag = 'iter' ; end
        if k == options.Generations
            flag = 'done' ;
            exitflag = 0 ;
        end
        
        if strcmpi(flag,'done')
            break
        end % if strcmpi
        
        % Update the particle velocities and positions
        state = psoiterate(options,state,flag) ;
        averagetime = t1/k ;
    end % for k
    state.Population=statePopulation;
else
    stateScoreTmp=inf*ones(n,1); %can't be larger, won't necessarily use all of it
    for k = 1:options.Generations
        state.Score = inf*ones(n,1) ; % Reset fitness vector
        state.Generation = k ;
        state.OutOfBounds = false(options.PopulationSize,1) ;
        
        % Check bounds before proceeding
        if ~isequal(boundsCheckFn,@boundsPenalize) && ...
                ~all(isempty([LB;UB]))
            state = boundsCheckFn(state,LB,UB) ;
        end
        
        % Evaluate fitness
        if options.UseParallel
            validi=setdiff(1:n,find(state.OutOfBounds));
            nvalid=numel(validi);
            currStatePop=state.Population(validi,:);
            parfor i = 1:nvalid
                stateScoreTmp(i) = feval(objfuncPf.Value,currStatePop(i,:)) ;
            end
            for i = 1:nvalid
                state.Score(validi(i))=stateScoreTmp(i);
            end
        else
            for i = setdiff(1:n,find(state.OutOfBounds))
                state.Score(i) = feval(tobj,state.Population(i,:));
            end
        end
        
        % Check bounds before proceeding ('penalize' needs special treatment)
        if isequal(boundsCheckFn,@boundsPenalize) && ~all(isempty([LB;UB]))
            state = boundsCheckFn(state,LB,UB) ;
        end
        
        % Update the local bests
        betterindex = state.Score < state.fLocalBests ;
        state.fLocalBests(betterindex) = state.Score(betterindex) ;
        state.xLocalBests(betterindex,:) = ...
            state.Population(betterindex,:) ;
        
        % Update the global best and its fitness, then check for termination
        [minfitness, minfitnessindex] = min(state.Score) ;
        
        if minfitness < state.fGlobalBest
            state.fGlobalBest(k) = minfitness ;
            state.xGlobalBest = state.Population(minfitnessindex,:) ;
            state.LastImprovement = k ;
            imprvchk = k > options.StallGenLimit && ...
                (state.fGlobalBest(k - options.StallGenLimit) - ...
                state.fGlobalBest(k)) / (k - options.StallGenLimit) < ...
                options.TolFun ;
            if imprvchk
                exitflag = 1 ;
                flag = 'done' ;
            elseif state.fGlobalBest(k) < options.FitnessLimit
                exitflag = 2 ;
                flag = 'done' ;
            end % if k
        elseif k > 1 % No improvement from last iteration
            state.fGlobalBest(k) = state.fGlobalBest(k-1) ;
        end % if minfitness
        
        stall = k - state.LastImprovement ;
        stallchk = stall >= options.StallGenLimit ;
        if stallchk
            % No improvement for StallGenLimit generations
            exitflag = 3 ;
            flag = 'done' ;
        end
        
        t1=toc(t0);
        if t1 + averagetime > options.TimeLimit
            exitflag = 5 ;
            flag = 'done' ;
        end
        
        % Update flags, state and plots before updating positions
        if k == 2, flag = 'iter' ; end
        if k == options.Generations
            flag = 'done' ;
            exitflag = 0 ;
        end
        
        if ~isempty(options.PlotFcns) && ~mod(k,options.PlotInterval)
            % Exit gracefully if user has closed the figure
            if isempty(findobj('Tag','PSO Plots','Type','figure'))
                exitflag = -1 ;
                break
            end % if isempty
            % Find a good size for subplot array
            rows = floor(sqrt(length(options.PlotFcns))) ;
            cols = ceil(length(options.PlotFcns) / rows) ;
            % Cycle through plotting functions
            if strcmpi(flag,'init')
                haxes = zeros(length(options.PlotFcns),1) ;
            end % if strcmpi
            for i = 1:length(options.PlotFcns)
                if strcmpi(flag,'init')
                    haxes(i) = subplot(rows,cols,i,...
                        'Parent',state.hfigure) ;
                    set(gca,'NextPlot','replacechildren')
                else
                    subplot(haxes(i))
                end % if strcmpi
                if iscell(options.PlotFcns)
                    options.PlotFcns{i}(options,state,flag) ;
                else
                    options.PlotFcns(options,state,flag) ;
                end
            end % for i
            drawnow
        end % if ~isempty
        
        if options.Verbosity>2 && toc(t2)>options.UpdateInterval
            t2=tic;
            fprintf(1,'[%g] min(f) = %g, stall = %g\n',k,state.fGlobalBest(k),stall) ;
        end
        
        if strcmpi(flag,'done'), break; end
        
        % Update the particle velocities and positions
        state = psoiterate(options,state,flag) ;
        averagetime = t1/k ;
    end % for k
end %if options.UseParallel && not(constr)
if options.Verbosity>2
    fprintf(1,'[%g] min(f) = %g, stall = %g\n',k,state.fGlobalBest(k),stall) ;
end

% Assign output variables and generate output
X1 = state.xGlobalBest ;
fval = state.fGlobalBest(k) ; % Best fitness value
% Final population: (hopefully very close to each other)
population = state.Population ;
scores = state.Score ; % Final scores (NOT local bests)
output.generations = k ; % Number of iterations performed


doDisplayFinal(options,output,exitflag) ;

% Check for hybrid function, run if necessary
if ~isempty(options.HybridFcn) && exitflag ~= -1
    [X1,fval] = feval(@doHybrid,tobj,X1,LB,UB,options) ;
end

% Wrap up
if options.Verbosity > 0
    if exitflag == -1
        fprintf('\nBest point found: %s\n\n',mat2str(X1,5))
    else
        fprintf('\nFinal best point: %s\n\n',mat2str(X1,5))
    end
end % if options.Verbosity

LAMBDA.lower=(X1<=LB);
LAMBDA.upper=(X1>=UB);
end










%% Subfunctions
function initrange = psocheckpopulationinitrange(initrange,LB,UB)
% Automatically adjust PopInitRange according to provided LB and UB.

lowerRange = initrange(1,:) ;
upperRange = initrange(2,:) ;

lowerInf = isinf(LB) ;
index = false(size(lowerRange,2),1) ;
index(~lowerInf) = LB(~lowerInf) ~= lowerRange(~lowerInf) ;
lowerRange(index) = LB(index) ;

upperInf = isinf(UB) ;
index = false(size(upperRange,2),1) ;
index(~upperInf) = LB(~upperInf) ~= upperRange(~upperInf) ;
upperRange(index) = UB(index) ;

initrange = [lowerRange; upperRange] ;
end

function [state,flag] = psoiterate(options,state,flag)
% Updates swarm positions and velocities. Called to iterate the swarm from
% the main PSO function. This function can handle binary and double-vector
% "genomes".

% Weightings for inertia, local, and global influence.
C0 = state.ParticleInertia ;
C1 = options.CognitiveAttraction ; % Local (self best point)
C2 = options.SocialAttraction ; % Global (overall best point)
n = size(state.Population,1) ;
nvars = size(state.Population,2) ;

% lowerinertia = (C1 + C2)/2 - 1 ;
lowerinertia = 0.4 ;
upperinertia = max(0.9,lowerinertia) ;

% Random number seed
R1 = rand(n,nvars) ;
R2 = rand(n,nvars) ;

R1(isinf(state.fLocalBests),:) = 0 ;

% Calculate matrix of velocities state.Velocities for entire population
state.Velocities = C0.*state.Velocities + ...
    C1.*R1.*(state.xLocalBests - state.Population) + ...
    C2.*R2.*(repmat(state.xGlobalBest,n,1) - state.Population) ;
state = checkmaxvelocities(state,options) ;
state.Population = state.Population + state.Velocities ;

% Update behavioral parameters: reduced inertial term
state.ParticleInertia = upperinertia - ...
    lowerinertia*(state.Generation-1) / ...
    (options.Generations-1) ;
end

function state = checkmaxvelocities(state,options)
% Checks the particle velocities against options.VelocityLimit

if ~isempty(options.VelocityLimit) && ... % Check max velocities
        any(isfinite(options.VelocityLimit))
    state.Velocities = min(state.Velocities, ...
        repmat(options.VelocityLimit,n,1)) ;
    state.Velocities = max(state.Velocities, ...
        repmat(-options.VelocityLimit,n,1)) ;
end
end

function state = psocreationuniform(options,nvars)
% Generates uniformly distributed swarm based on options.PopInitRange.

n = options.PopulationSize ;
itr = options.Generations ;

[state,nbrtocreate] = initPop(options,n,nvars) ;

% Initialize particle positions
state.Population(n-nbrtocreate+1:n,:) = ...
    repmat(options.PopInitRange(1,:),nbrtocreate,1) + ...
    repmat((options.PopInitRange(2,:) - options.PopInitRange(1,:)),...
    nbrtocreate,1).*rand(nbrtocreate,nvars) ;

% Initial particle velocities are zero by default (should be already set in
% PSOGETINTIALPOPULATION).

% Initialize the global and local fitness to the worst possible
state.fGlobalBest = ones(itr,1)*inf; % Global best fitness score
state.fLocalBests = ones(n,1)*inf ; % Individual best fitness score

% Initialize global and local best positions
state.xGlobalBest = ones(1,nvars)*inf ;
state.xLocalBests = ones(n,nvars)*inf ;
end

function [state, nbrtocreate] = initPop(options,n,nvars)
nbrtocreate = n ;
state.Population = zeros(n,nvars) ;
if ~isempty(options.InitialPopulation)
    nbrtocreate = nbrtocreate - size(options.InitialPopulation,1) ;
    state.Population(1:n-nbrtocreate,:) = options.InitialPopulation ;
    if options.Verbosity > 2, disp('Found initial population'), end
end

% Initial particle velocities
state.Velocities = zeros(n,nvars) ;
if ~isempty(options.InitialVelocities)
    state.Velocities(1:size(options.InitialVelocities,1),:) = ...
        options.InitialVelocities ;
    if options.Verbosity > 2
        disp('Found initial velocities') ;
    end
end
end

function state = ...
    boundsSoft(state,LB,UB,~)

x = state.Population ;

for i = 1:size(state.Population,1)
    lowindex = [ ] ; highindex = [ ] ;
    if ~isempty(LB), lowindex = x(i,:) < LB ; end
    if ~isempty(UB), highindex = x(i,:) > UB ; end
    
    outofbounds = any([lowindex,highindex]) ;
    
    if outofbounds
        state.Score(i) = inf ;
    end
    
    state.OutOfBounds(i) = outofbounds ;
end

state.Population = x ;
end

function state = ...
    boundsReflect(state,LB,UB,~)

x = state.Population ;
v = state.Velocities ;

for i = 1:size(state.Population,1)
    lowindex = [ ] ; highindex = [ ] ;
    if ~isempty(LB), lowindex = x(i,:) < LB ; end
    if ~isempty(UB), highindex = x(i,:) > UB ; end
    
    x(i,lowindex) = LB(lowindex) ;
    x(i,highindex) = UB(highindex) ;
    v(i,lowindex) = -v(i,lowindex) ;
    v(i,highindex) = -v(i,highindex);
end

state.Population = x ;
state.Velocities = v ;
end

function state = boundsPenalize(state,LB,UB,options)
% This is like "soft" boundaries, except that some kind of penalty value
% must be calculated from the degree of each constraint violation.

x = state.Population ;

state.OutOfBounds = false(size(state.Population,1),1) ;
state.Penalty = zeros(size(state.Population,1),1) ;

nLB = size(LB,2) ;
nUB = nLB + size(UB,2) ;

f = abs(mean(state.Score)) ;
g = zeros(options.PopulationSize,nconstr) ;

for i = 1:options.PopulationSize
    if ~isempty(LB)
        g(i,1:nLB) = max([LB - x(i,:) ;
            zeros(1,size(state.Population,2))]) ;
    end
    
    if ~isempty(UB)
        g(i,nLB+1:nUB) = max([x(i,:) - UB ;
            zeros(1,size(state.Population,2))]) ;
    end
    
    if any(g(i,:)), state.Velocities(i,:) = 0 ; end
end

state.Penalty = calculatePenalties(f,g,options) ;
state.Score = state.Score + state.Penalty ;
state.Population = x ;
% state.Velocities = v ;
end

function penalty = calculatePenalties(f,g,options)

ssg = sum(mean(g,1).^2,2) ;
penalty = zeros(options.PopulationSize,1) ;
if ssg > options.TolCon ;
    k = zeros(1,size(g,2)) ;
    for i = 1:size(g,1)
        for j = 1:size(g,2)
            k(i,j) = f*mean(g(:,j),1)/ssg ;
        end
        penalty(i) = k(i,:)*g(i,:)' ;
    end
end
end

function state = boundsAbsorb(state,LB,UB,~)

x = state.Population ;
v = state.Velocities ;

for i = 1:size(state.Population,1)
    lowindex = [ ] ; highindex = [ ] ;
    if ~isempty(LB), lowindex = x(i,:) < LB ; end
    if ~isempty(UB), highindex = x(i,:) > UB ; end
    % Check against bounded constraints
    x(i,lowindex) = LB(lowindex) ;
    x(i,highindex) = UB(highindex) ;
    v(i,lowindex) = 0 ;
    v(i,highindex) = 0 ;
end

state.Population = x ;
state.Velocities = v ;

end

function doDisplayFinal(options,output,exitflag)
if options.Verbosity > 0
    if exitflag == 0
        fprintf(1,'Reached limit of %g iterations\n',options.Generations) ;
    elseif exitflag == 1
        fprintf(1,'Average cumulative change in value of the fitness function over %g generations less than %g and constraint violation less than %g, and constraint violation less than %g, after %g generations.\n', ...
            options.StallGenLimit,options.TolFun,options.TolCon,output.generations) ;
    elseif exitflag == 2
        fprintf(1,'Fitness limit %g reached and constraint violation less than %g.\n', ...
            options.FitnessLimit,options.TolCon) ;
    elseif exitflag == 3
        fprintf(1,'The value of the fitness function did not improve in the last %g generations and maximum constraint violation is less than %g after %g generations\n',...
            options.StallGenLimit,options.TolCon,output.generations) ;
    elseif exitflag == 5
        fprintf(1,'Time limit of %g seconds has been exceeded after %g generations.',...
            options.TimeLimit,output.generations) ;
    elseif exitflag == -1
        fprintf(1,'Optimization stopped by user\n') ;
    else
        fprintf(1,'Unrecognized exitflag value\n') ;
    end
end
end

%% Hybrid stuff
function [X1,fval] = doHybrid(tobj,X1,...
    LB,UB,options,varargin)

if iscell(options.HybridFcn)
    if ischar(options.HybridFcn{1})
        HybridFcn = options.HybridFcn{1};
    else
        HybridFcn = func2str(options.HybridFcn{1}) ;
    end
    hybridOptions = options.HybridFcn{2} ;
    if iscell(hybridOptions)
        hybridOptions = optimset(hybridOptions{:}) ;
    end
elseif islogical(options.HybridFcn)
    if all(all(isempty([LB;UB]))) || all(all(isinf([LB;UB])))
        HybridFcn = 'fminunc' ;
    else
        HybridFcn = 'fmincon' ;
    end
    hybridOptions = optimset('Display',options.Display,...
        'LargeScale','off') ;
    if isfield(hybridOptions,'Algorithm')
        hybridOptions.Algorithm = 'active-set' ;
    end
else
    if ischar(options.HybridFcn)
        HybridFcn = options.HybridFcn;
    else
        HybridFcn = func2str(options.HybridFcn) ;
    end
    hybridOptions = optimset('Display',options.Display,...
        'LargeScale','off') ;
    if isfield(hybridOptions,'Algorithm')
        hybridOptions.Algorithm = 'active-set' ;
    end
end

if options.Verbosity > 0
    fprintf(1,'\nBest point before hybrid function: %s',mat2str(X1,5));
    fprintf(1,'\n\nTurning over to hybrid function %s...\n',HybridFcn);
end

% Check for constraints
if strcmp(HybridFcn,'fmincon') && ...
        all(isempty([LB;UB]))
    if options.Verbosity>0
        fprintf(1,'Warning: fmincon does not accept problems without constraints. Switching to fminunc.\n');
    end
    HybridFcn = 'fminunc' ;
elseif strcmp(HybridFcn,'fminunc') && ...
        ~all(isempty([LB;UB]))
    if options.Verbosity>0
        fprintf(1,'Warning: fminunc does not accept problems with constraints. Switching to fmincon.\n');
    end
    HybridFcn = 'fmincon' ;
end

if strcmp(HybridFcn,'fmincon')
    [X1,fval] = fmincon(tobj,X1,[ ],[ ],...
        [ ],[ ],LB,UB,[ ],hybridOptions) ;
elseif strcmp(HybridFcn,'fminunc')
    [X1,fval] = fminunc(tobj,X1,hybridOptions) ;
else
    warning('pso:hybridfcn:unrecognized',...
        'Unrecognized hybrid function. Ignoring for it now.')
end
end

function options=xxHybridDefaults(options,LB,UB)
if ~isempty(LB) && ~isempty(UB)
    if all(isinf(LB)) && all(isinf(UB))
        if options.Verbosity>0
            fprintf(1,'Optimization Toolbox available for unconstrained problem: setting HybridFcn to fminunc.\n');
        end
        options.HybridFcn='fminunc';
    else
        if options.Verbosity>0
            fprintf(1,'Optimization Toolbox available for constrained problem: setting HybridFcn to fmincon.\n');
        end
        options.HybridFcn='fmincon';
    end
else
    if options.Verbosity>0, fprintf(1,'Optimization Toolbox available for constrained problem: setting HybridFcn to fmincon.\n'); end
    options.HybridFcn='fmincon';
end
end
