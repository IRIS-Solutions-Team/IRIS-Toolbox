classdef individual
    
    properties
        age
        gene
        LB
        UB
        parentGene
        parentFitness
        mutationType
        mutationParam
        crossoverType
        fitness = NaN
        H0
        g0 = [ ] 
        fitnessFn
        size
        nFunEval
        agingMethod
        useInertia = false
        inertia
    end
    
    methods
        function val = maxAge(varargin)
            val = 0 ;
            for p = 1:numel(varargin)
                val = max(varargin{p}.age,val) ;
            end
        end
        
        function This = individual(gene,mutationType,crossoverType,LB,UB,options)
            pp = inputParser( ) ;
            pp.addRequired('gene',@(x) isnumeric(x) || islogical(x) || isfunc(x)) ;
            pp.parse(gene) ;
            
            This.age = 1 ;
            This.mutationType = mutationType ;
            This.crossoverType = crossoverType ;
            if any(LB>UB)
                utils.error('irisoptim:individual',...
                    'inconsistent bounds.') ;
            end
            This.LB = LB ;
            This.UB = UB ;
            if ( isnumeric(gene) && ~isempty(gene) ) ...
                    && ( any(LB>gene) || any(UB<gene) )
                utils.error('irisoptim:individual',...
                    'initial gene does not respect bounds.') ;
            end
            This.gene = gene ;
            This.mutationParam = options.mutationParam ;
            This.fitnessFn = options.fitnessFn ;
            This.size = numel(LB) ;
            This.H0 = eye(This.size) ;
            This.nFunEval = 0 ;
            This.agingMethod = options.agingMethod ;
            This.inertia = zeros(This.size,1) ;
            This.useInertia = options.useInertia ;
        end
        
        function Collection = elite(varargin)
            if isnumeric(varargin{1})
                n = varargin{1} ;
                varargin(1) = [ ] ;
            elseif isnumeric(varargin{end})
                n = varargin{end} ;
                varargin(end) = [ ] ;
            else
                n = 1 ;
            end
            
            np = numel(varargin);
            if np==n
                for p = 1:np
                    varargin{p}.age = varargin{p}.age + 1 ;
                end
                Collection = varargin ;
            else
                fitness = zeros(1,np) ;
                for p = 1:np
                    fitness(p) = varargin{p}.fitness ;
                    varargin{p}.age = varargin{p}.age + 1 ; %just in case
                end
                [~,bestInd] = sort(fitness,2,'descend') ;
                Collection = varargin(bestInd(1:n)) ;
            end
        end
        
        function varargout = recombine(varargin)
            % Takes a collection of parents and
            % produces one offspring
            np = numel(varargin) ;
            
            if strcmpi(varargin{1}.crossoverType,'hill')
                for p = 1:np
                    if ~strcmpi(varargin{1}.mutationType,'none') || isempty(varargin{p}.g0)
                        g0 = xxGrad(varargin{p}.fitnessFn,varargin{p}.gene,varargin{p}.fitness) ;
                    else
                        g0 = varargin{p}.g0 ;
                    end
                    H0 = varargin{p}.H0 ;
                    if isnan(rcond(H0)) 
                        H0 = eye(size(H0)) ;
                    end
                    if det(H0)<=0
                        H0 = H0 - (min(diag(H0))-1e-7)*eye(size(H0)) ; %#ok<*CPROP>
                    end
                    step = -H0\g0 ;
                    gene1 = varargin{p}.gene + step ;
                    [g1,f1] = xxGrad(varargin{p}.fitnessFn,varargin{p}.gene) ;
                    dg = g1 - g0 ;
                    H1 = H0 - ( H0*(step*step')*H0 )/(step'*H0*step) ...
                        + (dg*dg')/(dg'*step) ;
                    if not( isnan(f1) || isinf(f1) || any(isnan(gene1)) || any(isinf(gene1)) )
                        varargin{p}.H0 = H1 ;
                        varargin{p}.fitness = f1 ;
                        varargin{p}.g0 = g1 ;
                        varargin{p}.gene = gene1 ;
                        switch varargin{p}.agingMethod
                            case 'funevals'
                                if ~strcmpi(varargin{1}.mutationType,'none')
                                    increment = numel(g1) + 1 ;
                                else
                                    increment = 2*numel(g1) + 1 ;
                                end
                            case 'generations'
                                increment = 1 ;
                        end
                        varargin{p}.age = varargin{p}.age + increment ;
                    end
                end
                varargout = varargin ;
            else %#ok<*PROP>
                Child = varargin{1} ;
                gs = numel(varargin{1}.gene) ;
                switch varargin{1}.agingMethod
                    case 'generations'
                        Child.age = maxAge(varargin{:}) + 1 ;
                    case 'funevals'
                        s = 0 ;
                        for p = 1:numel(varargin)
                            s = s + varargin{p}.age ;
                        end
                        Child.age = s ;
                end
                
                switch varargin{1}.crossoverType
                    case 'uniform'
                        for iGene = 1:numel(Child.gene)
                            pgc = randperm(np,1) ;
                            Child.gene(iGene) = varargin{pgc}.gene(iGene) ;
                        end
                        
                    case {'convex','arithmetic'}
                        gene = zeros(varargin{1}.size,1) ;
                        rat = (1/np) ;
                        for ip = 1:numel(varargin)
                            gene = gene + rat*varargin{ip}.gene ;
                        end
                        Child.gene = gene ;
                        
                    case 'one-point'
                        if np==2
                            r = randperm(gs,1) ;
                            gene = zeros(varargin{1}.size,1) ;
                            gene(1:r) = varargin{1}.gene(1:r) ;
                            gene(r+1:end) = varargin{2}.gene(r+1:end) ;
                            Child.gene = gene ;
                        else
                            utils.error('irisoptim:individual:crossover', ...
                                'one-point crossover is only valid when there are two parents.') ;
                        end
                        
                    case 'two-point'
                        r1 = randperm(gs,1) ;
                        r2 = randperm(gs,1) ;
                        if r1>r2
                            [r1,r2] = deal(r2,r1) ;
                        end
                        gene = zeros(varargin{1}.size,1) ;
                        gene(1:r1) = varargin{1}.gene(1:r1) ;
                        gene(r1+1:r2) = varargin{2}.gene(r1+1:r2) ;
                        gene(r2:end) = varargin{1}.gene(r2:end) ;
                        Child.gene = gene ;
                        
                    otherwise
                        utils.error('irisoptim:individual:crossover',...
                            'invalid crossover type.') ;
                end
                
                if varargin{1}.useInertia
                    Child.gene = Child.gene + 0.5*Child.inertia ;
                    Child.parentGene = zeros(gs,np) ;
                    Child.parentFitness = zeros(1,np) ;
                    for p = 1:np
                        Child.parentGene(:,p) = varargin{p}.gene ;
                        Child.parentFitness(p) = varargin{p}.fitness ;
                    end
                    mp = 0.8 ;
                    Child.inertia = mp*Child.inertia + (1-mp)*( Child.gene - mean(Child.parentGene,2) ) ;
                end
                varargout{1} = Child ;
            end
            
            function [g,lf0] = xxGrad(fun,x,lf0)
                if nargin<3
                    lf0 = fun(x) ;
                end
                e = eps^(1/3) ;
                nx = numel(x) ;
                g = NaN(nx,1) ;
                for ii = 1:nx
                    ee = e*max(abs(x(ii)),1)*sign(x(ii)) ;
                    tmp = x(ii) + ee ;
                    ee = tmp - x(ii) ;
                    xf = x ;
                    xf(ii) = x(ii) + ee ;
                    g(ii) = (fun(xf)-lf0)/ee ;
                end
            end
        end
        
        function This = mutate(This)
            if ischar(This.mutationType)
                if isfunc(This.mutationParam)
                    param = feval(This.mutationParam,This.age) ;
                else
                    param = This.mutationParam ;
                end
                x = This.gene ;
                switch This.mutationType
                    case 'none'
                        return
                        
                    case 'gaussian'
                        This.gene = x + ...
                            param*randn(This.size,1) ;
                        
                    case 'cauchy'
                        This.gene = x + param*tan( pi*(rand(This.size,1)-0.5) ) ;
                        
                    case 'flipbit'
                        if all(x==1|x==0)
                            % logical
                            np = param ;
                            flipThese = randperm(numel(x),np) ;
                            This.gene(flipThese) = ~This.gene(flipThese) ;
                        end
                        
                    otherwise
                        utils.error('irisoptim:individual:mutate',...
                            'invalid mutation type.') ;
                end
                This.gene = min(max(This.gene,This.LB),This.UB) ;
            else
                % is func
                This.gene = This.mutationParam(This.gene) ;
            end
            This.fitness = NaN ; %safeguard
        end
    end
    
end
