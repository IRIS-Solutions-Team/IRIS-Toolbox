function [xf,obj,lambda,hist] = alps(varargin)
% alps  Age layered population structure optimization algorithms, nesting standard genetic algorithm.
%
%
% Syntax
% =======
%
%     [X1,F] =  irisoptim.alps(Fun,X0,LB,UB,...)
%
%
% Input arguments
% ================
%
% * `Fun` [ function_handle ] - Handle to the function to be optimized.
%
% * `X0` [ numeric ] - Initial values (can be an array, a vector, or
% empty).
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
% * `'display='` [ `'off'` | `'final'` | *`'iter'`* ] - Level of display in
% order of increasing verbosity.
%
% * `'ageGap='` [ numeric | *20* ] - Age stratification parameter.
%
% * `'ageSeparation='` [ *'linear'* | 'polynomial' | 'exponential' ] - Age
% stratification function.
%
% * `'crossoverType='` [ *'uniform'* | 'convex' | 'one-point' |
% 'two-point' ] - Crossover/recombination type. With uniform recombination
% each gene is selected from the pool of parents with equal probability.
% With convex recombination genes are an equally-weighted convex
% combination of parent genes. One and two point crossover refer to
% selection types for two parents in which the child gene is a randomly
% sized partition from the gene of one parent with the remainder of the
% genes taken from the other parent.
%
% * `'elite='` [ numeric | *3* ] - Number of elite individuals per layer
% (set to zero to turn off elitism).
% 
% * `'hybrid='` [ logical | function_handle | cell | 'fmincon' | *false*
% 'irismin' ] - Perform second stage search using another optimization 
% routine after ALPS. 
% 
% * `'includeInitialValue='` [ logical | *false* ] - Include input gene(s)
% in initial population. 
% 
% * `'initType='` [ *'uniform'* | function_handle ] - Method to use for
% initializing new genes. The default is to initialize genes from a uniform
% distribution with support taken from the problem bounds. To initialize
% genes from a prior distribution use the option 'prior='. 
%
% * `'layers='` [ numeric | *10* ] - Number of age stratification layers.
%
% * `'maxIt='` [ numeric | *1e+8* ] - Maximum number of
% iterations/generations.
%
% * `'mutationType='` [ *'cauchy'* | 'gaussian' | 'flipbit' | 'none' ]
% - Mutation algorithm. Cauchy and Gaussian add a random variable from that
% distribution to the paramter. Flipbit is appropriate for optimization of
% logical vectors.
%
% * `'mutationParam='` [ numeric | function_handle | *@(x) exp(-x)* ] - 
% Controls the standard deviation of the random variable, potentially as 
% a function of the age of the individual, when 'mutationType=', is 
% 'cauchy' or 'gaussian'.
%
% * `'nParents='` [ numeric | @auto ] - Number of parents selected for
% reproduction. By default the number of parents is four, unless
% 'crossoverType=' is 'one-point' or 'two-point', in which case the number
% of parents is two.
%
% * `'plot='` [ 'plotfitness' | function_handle | cell ] - Function handles
% or names of built-in plotting functions.
% 
% * `'prior='` [ struct | *[ ]* ] - Include prior structure for state space 
% model (see [`model/estimate`](model/estimate)) to initialize new genes 
% from prior distribution. Overrides option 'initType='. 
%
% * `'populationSize='` [ numeric | *100* ] - Number of individuals per
% layer.
%
% * `'selectionType='` [ *'tournament'* | 'universal' | 'proportionate'
% | 'truncation' | 'rank' ] - Natural selection algorithm. Tournament
% selection ranks individuals and selects parents based on a geometric
% distribution. Proportionate sampling selects individuals with probability
% proportional to their fitness. Universal refers to stochastic universal
% sampling and chooses parents based on a randomly shifted fixed interval
% method, and is typically preferable to fitness proportionate selection.
% Truncation selects the best N parents
%
% * `'selectionParam='` [ numeric | function_handle ] - Selection parameter
% which controls the geometric distribution when
% 'selectionType=' is 'tournament'.
%
% * `'stall='` [ numeric | *1000* ] - Terminate evolution if no improvements
% in the best known gene are found after this number of generations. 
%
%
% Description
% ============
%
% Implements the age layered population structure evolutionary algorithm
% from Hornby (2006) and Hornby (2009). Nests standard non-stratified
% genetic algorithm (like the one in the MATLAB Global Optimization
% Toolbox) when the number of layers is set to 1. 
%
%
% Examples
% =========
%
%
% References
% ===========
%
% * Hornby, G. S. (2006) "ALPS: The Age-Layered Population Structure for
% Reducing the Problem of Premature Convergence", Proc. of the Genetic and
% Evolutionary Computation Conference, ACM Press.
%
% * Hornby, G. S. (2009) "A Steady-State Version of the Age-Layered
% Population Structure EA" , Genetic Programming Theory & Practice VII.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c1) 2007-2021 IRIS Solutions Team.

[F,X0,LB,UB,varargin] = ...
    irisinp.parser.parse('irisoptim.alps',varargin{:});

options = passvalopt('irisoptim.alps',varargin{:}) ;

N = options.layerSize ;
options.LB = LB(:) ;
options.UB = UB(:) ;
options.LB(isinf(LB(:))) = -10 ;
options.UB(isinf(UB(:))) = 10 ;

dispIter = any(strcmpi(options.display,{'iter','debug'})) ;
dispDebug = strcmpi(options.display,'debug') ;
options.fitnessFn = [ ] ;
geneSize = numel(UB) ;

if ~isempty(options.prior)
    options.initType = cell(geneSize,1) ;
    E = options.prior ;
    names = fields(E) ;
    for gg = 1:geneSize
        options.initType{gg} = E.(names{gg}){4} ;
    end
end

if islogical(options.hybrid) && options.hybrid==true
    hybrid = true ;
    options.optimset = { } ;
    options.solver = 'fmincon' ;
elseif iscell(options.hybrid) && isfunc(options.hybrid{1})
    hybrid = true ;
    options.optimset = options.hybrid ;
elseif ischar(options.hybrid)
    options.solver = options.hybrid ;
else
    hybrid = false ;
end

if strcmpi(options.crossoverType,'one-point')
    if options.nparents ~= 2
        utils.warning('irisoptim:alps','Setting number of parents to 2 for compatability with one-point crossover type.') ;
        options.nparents = 2 ;
    end
end

hist = [ ] ;

tobj = @(x) -feval(F,x) ;
options.fitnessFn = tobj ;

if options.parallel
    spmd
        if labindex==1
            tpobj = tobj ;
            labBroadcast(1,tpobj) ;
        else
            tpobj = labBroadcast(1) ;
        end
    end
end

Layer = cell(options.layers,1) ;
Layer{1} = irisoptim.layer(N,1,maxAllowableAge(1),options) ;
Layer{1} = Layer{1}.initPop( ) ;
if options.includeInitialValue && ~isempty(X0)
    if size(X0,2)==length(LB) && size(X0,1)~=length(LB)
        X0 = transpose(X0) ;
    end
    m = size(X0,2) ;
    for p = 1:m
        Layer{1}.population{p}.gene = X0(:,p) ;
    end
end

C = 1 ;

nLay = options.layers ;
nElite = double(options.elite) ;
layerFitness = NaN(nLay,N) ;

[colors,myAx] = doPlotInit( ) ;

for ii = 1:nLay
    Layer{ii} = irisoptim.layer(N,1,maxAllowableAge(ii),options) ;
    Layer{ii} = Layer{ii}.initPop( ) ;
end
C = nLay ;
doFitnessEvalAll( ) ;
it = 0 ;
doDisplayInit( ) ;
doDisplay( ) ;
while it<options.maxit
    it = it + 1 ;
    
    if newDna(it)
        ii = 1 ;
        if isempty(Layer{2})
            initNextLayer( ) ;
        else
            doMoveOldPeople( true ) ;
        end
        Layer{1} = Layer{1}.initPop( ) ;
    end
    
    for iL = 1:C 
        Layer{iL}.extras = { } ;
    end
    
    for ii = C:-1:1
        if it>options.stall ...
                && abs(hist(end)-hist(end-options.stall))<eps
            if dispIter || strcmpi(options.display,'final')
                fprintf(1,'Change in best fitness value less than machine precision after %g generations, terminating.\n',options.stall) ;
            end
            return ;
        end
        
        newPopulation = cell(1,N) ;
        if ii==1
            prevLayer = Layer{1} ;
        else
            % ii>1
            prevLayer = [Layer{ii},Layer{ii-1}] ;
        end
        
        % evolution
        if nElite>0
            eliteIndividuals = elite(prevLayer.population{:},nElite) ;
            newPopulation(1:nElite) = eliteIndividuals ;
        end
        for p = 1+nElite:N
            parents = selectdna(prevLayer,options.nparents) ;
            child = recombine(parents{:}) ;
            newPopulation{p} = mutate(child) ;
        end
        Layer{ii}.population = newPopulation ;
        
        % move old genes to next layer
        if ii<nLay
            doTransition( ) ;
        end
    end
    doFitnessEvalAll( ) ;
    for iL = 1:C
        thisPop = [Layer{iL}.population, Layer{iL}.extras] ;
        Layer{iL}.population = elite(thisPop{:},N) ;
    end
    doAdapt( ) ;
    doDisplay( ) ;
end
[obj,bestLayer,bestIndividual] = maxAll(layerFitness) ;
xf = Layer{bestLayer}.population{bestIndividual}.gene ;

if hybrid
    [xf,obj,~,lambda] = irisoptim.myoptimize(tobj,xf,LB,UB,options) ;
else
    lambda = struct( ) ;
    lambda.lower = ( xf(:) <= LB(:) );
    lambda.upper = ( xf(:) >= UB(:) );
end

    function doTransition( )
        if ii>1 && maxAge(Layer{ii}.population{:}) > Layer{ii}.maxAllowableAge
            doMoveOldPeople( false ) ;
        end
    end

    function [p] = doFitnessEvalAll( )
        % first get all genes which need to be evaluated
        genes = [ ] ;
        ind = [ ] ;
        for il = 1:nLay
            for p = 1:Layer{il}.size
                if isnan(Layer{il}.population{p}.fitness)
                    genes = [genes,Layer{il}.population{p}.gene] ;
                    ind = [ind; il, p] ;
                end
            end
        end
        NG = size(ind,1) ;
        
        if dispDebug
            if options.parallel
                str = 'parallel' ;
            else
                str = 'serial' ;
            end
            fprintf(1,'Evaluating %g genes in %s...\n',NG,str) ;
        end
        
        % evaluate in parallel or serial
        if options.parallel
            genesD = distributed(genes) ;
            spmd
                genesL = getLocalPart(genesD) ;
                nl = size(genesL,2) ;
                fitL = zeros(1,nl) ;
                for pp = 1:nl
                    fitL(pp) = tpobj(genesL(:,pp)) ;
                end
            end
            fitC = gather(fitL) ;
            fitArr = [fitC{:}] ;
        else
            fitArr = NaN(1,NG) ;
            for iGene = 1:NG
                fitArr(iGene) = tobj(genes(:,iGene)) ;
            end
        end
        
        % assign fitness values back based on genes
        for iGene = 1:NG
            Layer{ind(iGene,1)}.population{ind(iGene,2)}.fitness = fitArr(iGene) ;
        end
        for iLay = 1:nLay
            layerFitness(iLay,:) = Layer{iLay}.fitness ;
        end
    end

    function [p,pp,child,parents,genes,genesD,genesL,fitC,fitness,nl,fitL] = doMoveOldPeople(condition) %#ok<*STOUT>
        % condition true => layer 1 is being re-initalized, move based on
        % fitness, do not replace (will be replaced by new random dna)
        % condition false => move based on age and fitness
        if condition
            Layer{ii+1}.extras = Layer{ii}.population ;
        else
            if ii == 1
                prevLayer = Layer{1} ;
            else
                prevLayer = [Layer{ii},Layer{ii-1}] ;
            end
            theseExtras = { } ;
            for p = 1:N
                person = Layer{ii}.population{p} ;
                if person.age > Layer{ii}.maxAllowableAge
                    theseExtras = [theseExtras, {person}] ; %#ok<*AGROW>
                    % replace them with children
                    parents = selectdna(prevLayer,options.nparents) ;
                    child = recombine(parents{:}) ;
                    Layer{ii}.population{p} = mutate(child) ;
                end
            end
            Layer{ii+1}.extras = theseExtras ;
        end
        layerFitness(ii+1,:) = Layer{ii+1}.fitness ;
    end

    function doAdapt( )
    end

    function doDisplayInit( )
        if dispIter
            fprintf(1,'Optimizing using age layer population structure evolutionary algorithm...\n') ;
            fprintf(1,'Selection: \n') ;
            fprintf(1,'    Type: %s\n',options.selectionType) ;
            fprintf(1,'    Parameter: %s\n',utils.any2str(options.selectionParam)) ;
            fprintf(1,'Mutation: \n') ;
            fprintf(1,'    Type: %s\n',options.mutationType) ;
            fprintf(1,'    Parameter: %s\n',utils.any2str(options.mutationParam)) ;
            fprintf(1,'Crossover:\n') ;
            fprintf(1,'    Type: %s\n',options.crossoverType) ;
            fprintf(1,'Age separation: \n') ;
            fprintf(1,'    Type: %s\n',options.ageSeparation) ;
            fprintf(1,'    Parameter: %g\n',options.ageGap) ;
            fprintf(1,'Stall limit: %g\n',options.stall) ;
            fprintf(1,'Elite: %g\n',options.elite) ;
            fprintf(1,'Hybrid: %s\n',utils.any2str(options.hybrid)) ;
            fprintf(1,'Layers: %g\n',options.layers) ;
            fprintf(1,'Size: %g individuals per layer\n',options.layerSize) ;
            fprintf(1,'Parallel: ') ;
            if options.parallel
                fprintf(1,'true\n') ;
            else
                fprintf(1,'false\n') ;
            end
            fprintf(1,'Initialize new DNA using: ') ;
            if isempty(options.prior) 
                fprintf(1,'%s\n',utils.any2str(options.initType)) ;
            else
                fprintf(1,'prior distribution\n') ;
            end
            fprintf(1,'Number of parents: %g\n',options.nparents) ;
            fprintf(1,'Maximum number of generations: %g\n',options.maxit) ;
            fprintf(1,'\n') ;
        end
    end

    function doDisplay( )
        if dispIter
            [maxFit,bestLayer,bestIndividual] = maxAll(layerFitness) ;
            meanFit = -mean(mean(layerFitness(~isnan(layerFitness)))) ;
            xf = Layer{bestLayer}.population{bestIndividual}.gene ;
            
            fprintf(1,'[%g] min(f)= %g, mu(f)= %g',it,-maxFit,meanFit) ;
            if options.adaptive
                fprintf(', a=%g',mutationParam) ;
            end
            fprintf(1,'\n') ;
            if dispDebug
                fprintf('   argmin(f) = [') ;
                for ix = 1:numel(xf)-1
                    fprintf('%g,',xf(ix)) ;
                end
                fprintf('%g]\n',xf(end)) ;
                fprintf('   current layer = %g, age(bestx) = %g is person %g in layer %g\n',ii,Layer{bestLayer}.population{bestIndividual}.age,bestIndividual,bestLayer) ;
                
            end
        end
        if ~isempty(options.plot)
            for mm = 1:numel(options.plot)
                if strcmpi('plotfitness',options.plot{mm})
                    plotfitness(myAx{mm}) ;
                elseif strcmpi('plotclusters',options.plot{mm})
                    plotclusters(myAx{mm}) ;
                else
                    feval(options.plot{mm},myAx{mm},it,Layer) ;
                end
            end
            drawnow ;
        end
    end

    function plotfitness(ax1)
        persistent lh
        if isempty(lh)
            ylabel('-fitness(x)') ;
            xlabel('iteration') ;
            lh = [ ] ;
        end
        
        hold on
        for il = 1:C
            lf = Layer{il}.fitness ;
            plot(ax1,it-1:it,-max(lf)*ones(1,2),'color',colors(il,:)) ;
        end
        hold off
        if isempty(lh)
            layerNames = cell(nLay,1) ;
            for il = 1:nLay
                layerNames{il} = sprintf('Layer %g',il) ;
            end
            legend(layerNames) ;
            legend boxoff
            set(lh,'location','northeast') ;
        end
    end

    function X = maxAllowableAge(L)
        switch options.ageSeparation
            case 'linear'
                X = options.ageGap*L ;
                
            case 'polynomial'
                X = options.ageGap*L^2 ;
                
            case 'exponential'
                X = options.ageGap*(2^L) ;
                
            otherwise
                utils.error('irisoptim:alps','Unknown aging scheme.') ;
        end
    end

    function X = newDna(it)
        r = it/Layer{1}.maxAllowableAge ;
        X = floor(r)==r ;
    end

    function [v,ix,iy] = maxAll(X)
        [~,iy] = max(max(X)) ;
        [v,ix] = max(max(X,[ ],2)) ;
    end

    function [colors,myAx] = doPlotInit( )
        if ~isempty(options.plot)
            colors = colormap(jet(nLay)) ;
            nop = numel(options.plot) ;
            if nop==1
                subPlotLayout = [1,1] ;
            elseif nop==2
                subPlotLayout = [2,1] ;
            elseif nop>2 && nop<5
                subPlotLayout = [2,2] ;
            elseif nop>4 && nop<7
                subPlotLayout = [2,3] ;
            elseif nop>6
                subPlotLayout = [3,3] ;
            end
            for iax = 1:numel(options.plot)
                myAx{iax} = subplot(subPlotLayout(1),subPlotLayout(2),iax) ;
            end
        else
            colors = [ ] ;
            myAx = [ ] ;
        end
    end

end
