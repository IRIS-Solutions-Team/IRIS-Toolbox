classdef layer
    
    properties
        population
        extras = { } ;
        selectionType
        mutationType
        crossoverType
        elite
        previousLayer
        initType
        UB
        LB
        id
        size
        maxAllowableAge
        selectionParam
    end
    
    properties( Dependent=true )
        fitness
        gene
        diversity
    end
        
    methods
        function This = layer(N,id,maxAllowableAge,options)
            This.size = N ;
            This.population = cell(1,N) ;
            for ii = 1:N
                This.population{ii} ...
                    = irisoptim.individual([ ],...
                    options.mutationType,options.crossoverType,...
                    options.LB,options.UB,options) ;
            end
            This.id = id ;
            This.elite = options.elite ;
            This.LB = options.LB ;
            This.UB = options.UB ;
            This.crossoverType = options.crossoverType ;
            This.mutationType = options.mutationType ;
            This.selectionType = options.selectionType ;
            This.initType = options.initType ;
            This.maxAllowableAge = maxAllowableAge ;
            This.selectionParam = options.selectionParam ;
        end
        
        function This = initPop(This)
            N = numel(This.LB) ;
            for p = 1:This.size
                This.population{p}.age = 1 ;
                This.population{p}.fitness = NaN ;
            end
            if strcmpi(This.initType,'uniform')
                sample = rand(N,This.size) ;
                for p = 1:This.size
                    This.population{p}.gene = This.LB + sample(:,p).*(This.UB-This.LB) ;
                end
            elseif iscell(This.initType)
                ng = numel(This.initType) ;
                for p = 1:This.size
                    This.population{p}.gene = zeros(N,1) ;
                    for g = 1:ng
                        This.population{p}.gene(g) = min(max(This.LB(g),feval(This.initType{g},[ ],'draw')),This.UB(g)) ;
                    end
                end
            elseif isfunc(This.initType)
                for p = 1:This.size
                    This.population{p}.gene = feval(This.initType,This.LB,This.LB) ;
                end
            end
        end
        
        function These = selectdna(This,N)
            These = cell(1,N) ;
            fitVal = This.fitness ;
            
            switch This.selectionType
                case 'tournament'
                    f = @(p) ceil(log(rand)/log(1-p)) ;
                    [~,ind] = sort(fitVal,2,'descend') ;
                    for p = 1:N
                        pick = f(This.selectionParam) ;
                        These{p} = This.population{ind(min(pick,numel(ind)))} ;
                    end
                    
                case 'universal'
                    totalFitness = sum(fitVal) ;
                    points = NaN(1,N) ;
                    R = (totalFitness/N) ;
                    points(1) = rand( )*R ;
                    for ii = 2:N
                        points(ii) = points(ii-1) + R ;
                    end
                    
                    ii = 1 ;
                    fitnessSum = fitVal(1) ;
                    for p = 1:N
                        while fitnessSum<points(p) && ii<N
                            ii = ii + 1 ;
                            fitnessSum = fitnessSum + fitVal(ii) ;
                        end
                        These{p} = This.population{ii} ;
                    end
                    
                case {'propotionate','roulette'}
                    [sorted,ind] = sort(fitVal,2,'descend') ;
                    Sv = sorted/sum(fitVal) ;
                    Cdf = cumsum(Sv) ;
                    for ii = 1:N
                        winner = find(Cdf>rand( ),1) ;
                        These{ii} = This.population{ind(winner)} ;
                    end
                    
                case 'truncation'
                    [~,ind] = sort(fitVal,2,'descend') ;
                    These(:) = This.population(ind(1:N)) ;
                    
                case 'rank'
                    [~,ind] = sort(fitVal,2,'descend') ;
                    Pr = ind/numel(ind) ;
                    Cdf = cumsum(Pr) ;
                    for ii = 1:N
                        winner = find(Cdf>rand( ),1) ;
                        These{ii} = This.population{ind(winner)} ;
                    end
                    
                otherwise
                    utils.error('irisoptim:ga:layer',...
                        'Unsupported selection type.') ;
            end
        end
        
        function val = get.diversity(This)
            val = sqrt(sum(var(This.gene,0,2))) ;
        end
        
        function val = get.fitness(This)
            val = NaN(1,This.size) ;
            for ii = 1:This.size
                val(ii) = This.population{ii}.fitness ;
            end
        end
        
        function gene = get.gene(This)
            gene = zeros(This.population{1}.size,This.size) ;
            for p = 1:This.size
                gene(:,p) = This.population{p}.gene ;
            end
        end
        
        function C = horzcat(A,B)
            C = A ;
            C.population = [A.population,B.population] ;
        end
        
        function val = get.size(This)
            val = numel(This.population) ;
        end
    end
    
end
