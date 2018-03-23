function [This,xF,Obj] = estimate(This,Data,Range,varargin)
% estimate  Estimate artificial neural network parameters.
%
% Syntax
% =======
%
%     M = estimate(M,D,Range,...)
%
% Input arguments
% ================
%
% * `M` [ nnet ] - Neural network model object.
%
% * `D` [ dbase ] - Input database.
%
% * `Range` [ numeric ] - Evaluation range.
%
% Output arguments
% =================
%
% * `M` [ nnet ] - Estimated neural network model object.
%
% Options
% ========
%
% * `'display='` [ `'off'` | `'final'` | *`'iter'`* ] - Level of display in
% order of increasing verbosity.
%
% * `'learningRate='` [ numeric | *1* ] - Backpropogation learning rate.
%
% * `'maxiter='` [ numeric | *1e+5* ] - Maximum number of iterations.
%
% * `'optimSet='` [ cell | *empty* ] - Cell array of options for the
% optimizer. 
%
% * `'solver='` [ *`'backprop'`* | `'fmin'` | `'lsqnonlin'` | `'pso'` |
% | `'alps'` | function_handle ] - Optimization method to use for training.
%
% * `'tolx='` [ numeric | *1e-6* ] - Terminate backpropogation when the
% average of the maximum parameter change per iteration drops below this
% value. Will only terminate if backpropogation has trained on every
% observation in the training data at least once.
%
% * `'norm='` [ function_handle ] - Function for scoring networks. Default
% is the Euclidian norm. If using backpropogation, this option must be used
% in conjunction with 'normGradient='.
%
% * `'normGradient='` [ function_handle ] - Gradient of the norm function.
%
% * `'recomputeObjective='` [ numeric | function_handle | *1* ] - This
% option specifies how often the full objective function is computed as
% an integer indicating the frequency in observations or a handle to a
% function which returns true or false as a function of the iteration
% number and sample size (e.g., @(it,T) eq(T*floor(it/T), it)). The full
% objective function influences the termination criteria but does not
% otherwise affect backpropogation.
%
% * `'select='` [ cell ] - Select which classes of network parameters to
% train. Possible types include *`'activation'`*, `'output'`, and
% `'hyper'`. Not valid for backpropogation.
%
% References
% ===========
%
% * Duch, Wlodzislaw; Jankowski, Norbert (1999). "Survey of
% neural transfer functions," Neural Computing Surveys 2.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

pp = inputParser( ) ;
pp.addRequired('This',@(x) isa(x,'nnet')) ;
pp.addRequired('Data',@isstruct) ;
pp.addRequired('Range',@(x) isnumeric(x) && isvector(x)) ;
pp.parse(This,Data,Range) ;
if This.nAlt>1
    utils.error('nnet:estimate',...
        'Estimate does not support input neural network objects with multiple parameterizations.') ;
end

% Parse options
options = passvalopt('nnet.estimate',varargin{:}) ;
options = irisoptim.myoptimopts(options) ;
options.Select = nnet.myalias(options.Select) ;
options.Select = sort(options.Select) ;
if ( any(strcmpi(regexprep(varargin(1:2:end),'=',''),'Norm')) && strcmpi(options.solver,'backprop') ) ...
        && ~any(strcmpi(regexprep(varargin(1:2:end),'=',''),'NormGradient'))
    options.abp = false ;
end

% Get data
[InData,OutData] = datarequest('Inputs,Outputs',This,Data,Range) ;

% Backpropogation
%-----------------
if ischar(options.solver) && strncmpi(options.solver,'backprop',8)
    if isempty(options.abp)
        abp = true ;
        abpActSupport = {'linear'} ;
        abpOutSupport = {'logistic','s4','tanh','linear'} ;
        for iLayer = 1:This.nLayer
            if ~all(strcmpi(This.ActivationFn{iLayer},abpActSupport))
                abp = false ;
            end
            if ~all(strcmpi(This.OutputFn{iLayer},abpOutSupport))
                abp = false ;
            end
        end
        options.abp = abp ;
    end
    
    t0 = tic ;
    crit = 1e+10 ;
    predArr = OutData - eval(This,Data,Range) ;
    it = 0 ;
    This0 = This ;
    avgxch = 0 ;
    T = length(Range) ;
    samp = Range(randperm(T,T)) ;
    if strcmpi(options.display,'iter')
        fprintf(1,'Running backpropogation on %g observations...\n',T) ;
    end
    while crit>options.tolfun && it<options.maxiter
        it = it+1 ;
        if it>T
            obs = Range(randperm(length(Range),1)) ;
        else
            obs = samp(it) ;
        end
        [This,pErr] = bp(This,InData{obs,:},OutData{obs,:},options) ;
        if recompute( )
            predArr = OutData - eval(This,Data,Range) ;
        else
            % do not recompute full objective function every iteration for efficiency
            predArr(obs,:) = pErr(:)' ;
        end
        crit = options.Norm(predArr) ;
        xch = maxabs(This,This0) ;
        avgxch = (it-1)*(avgxch/it)+xch/it ;
        if it>=T && options.tolx>avgxch, break ; end
        if options.display
            myDate = dat2str(obs) ;
            fprintf(1,'[%g|%s] Objective: %g, Change in X: %g\n',it,myDate{1},crit,avgxch) ;
        end
        This0 = This ;
    end
    Obj = options.Norm( OutData-eval(This,Data,Range) ) ;
    if isanystri(options.display,{'iter','final'})
        fprintf(1,'Finished backpropogation training on %g observations after %g iterations for %g minutes.\n',T,it,toc(t0)/60) ;
        fprintf(1,'Objective: %g\n',Obj) ;
        if it>=options.maxiter
            fprintf(1,'Maximum number of iterations reached.\n') ;
        end
        if crit<=options.tolfun
            fprintf(1,'Function value below threshold of %g\n',options.tolfun) ;
        end
    end
else
    % Setup initial parameter vector and bounds
    lb = [ ] ;
    ub = [ ] ;
    x0 = [ ] ;
    for iOpt = 1:numel(options.Select)
        switch options.Select{iOpt}
            case 'activation'
                lb = [lb; get(This,'activationLB')] ;
                ub = [ub; get(This,'activationUB')] ;
                x0 = [x0; get(This,'activation')] ;
                
            case 'hyper'
                lb = [lb; get(This,'hyperLB')] ;
                ub = [ub; get(This,'hyperUB')] ;
                x0 = [x0; get(This,'hyper')] ;
                
            case 'output'
                lb = [lb; get(This,'outputLB')] ;
                ub = [ub; get(This,'outputUB')] ;
                x0 = [x0; get(This,'output')] ; %#ok<*AGROW>
                
        end
    end
    
    [xF,Obj] = irisoptim.myoptimize(@(x) objfunc(x,This,InData,OutData,Range,options),x0,lb,ub,options) ;
end

if ~strncmpi(options.solver,'backprop',8)
    Xcount = 0 ;
    for iOpt = 1:numel(options.Select)
        switch options.Select{iOpt}
            case 'activation'
                This = set(This,'activation',xF(1:This.nActivationParams)) ;
                Xcount = This.nActivationParams ;
                
            case 'hyper'
                This = set(This,'hyper',xF(Xcount+1:Xcount+This.nHyperParams)) ;
                Xcount = Xcount + This.nHyperParams ;
                
            case 'output'
                This = set(This,'output',xF(Xcount+1:Xcount+This.nOutputParams)) ;
                
        end
    end
end

    function X = recompute( )
        x = options.recompute ;
        if isfunc(x)
            if nargin(x)>1
                X = x(it,T) ;
            elseif nargin(x)==1
                X = x(it) ;
            else
                X = x( ) ;
            end
        elseif isnumericscalar(x)
            if x*floor(it/x) == x
                X = true ;
            else
                X = false ;
            end
        else
            utils.error('iris:nnet:estimate','Invalid recompute option.') ;
        end
    end



end

