function [sample,lp_Sample,len] ...
    = regen(This,NDraw,varargin)
% regen  Regeneration time MCMC Metropolis posterior simulator.
%
% Syntax
% =======
%
%     [Theta,LogPost,AR,Scale,FinalCov] = regen(Pos,NDraw,...)
%
% Input arguments
% ================
%
% * `Pos` [ poster ] - Initialised posterior simulator object.
%
% * `NDraw` [ numeric ] - Length of the chain not including burn-in.
%
% Output arguments
% =================
%
% * `Theta` [ numeric ] - MCMC chain with individual parameters in rows.
%
% * `LogPost` [ numeric ] - Vector of log posterior density (up to a
% constant) in each draw.
%
% * `AR` [ numeric ] - Vector of cumulative acceptance ratios in each draw.
%
% * `Scale` [ numeric ] - Vector of proposal scale factors in each draw.
%
% * `FinalCov` [ numeric ] - Final proposal covariance matrix; the final
% covariance matrix of the random walk step is `Scale(end)^2*FinalCov`.
%
% Options
% ========
% 
% References
% ===========
%
% * Brockwell, A.E., and Kadane, J.B., 2004. "Identification of
% Regeneration Times in MCMC Simulation, with Application to Adaptive
% Schemes," mimeo, Carnegie Mellon University.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team & Bojan Bejanov & Troy Matheson.

% Validate required inputs.
pp = inputParser( );
pp.addRequired('Pos',@(x) isa(x,'poster'));
pp.addRequired('NDraw',@isnumericscalar);
pp.parse(This,NDraw);


defaults = {
    'initialChainSize', 0.1, @(x) isnumericscalar(x) && x > 0
};


opt = passvalopt(defaults, varargin{:});

%--------------------------------------------------------------------------

if opt.initialChainSize < 1
    % initial chain size is a percentage
    opt.initialChainSize = floor(NDraw*opt.initialChainSize) ;
elseif opt.initialChainSize >= NDraw
    opt.initialChainSize = NDraw ;
    utils.warning('poster:regen',...
        'Initial chain size is larger than the number of requested draws.') ;
    opt.initialChainSize = min(NDraw,initialChainSize) ;
end

% Number of estimated parameters.
nPar = length(This.paramList);

% Generate initial chain for constructing reentry distribution and special K
[initSample,lp_initSample,initAccRatio,initSgm,initFinalCov] ...
    = arwm(This,opt.initialChainSize,'lastAdapt',1) ; %#ok<*ASGLU,*NASGU>
initStd = chol(cov(initSample')) ;
initMean = mean(initSample,2) ;

% Construct reentry distribution
reentryDist = logdist.normal(initMean,initStd) ;
reentrySample = reentryDist([ ],'draw',opt.initialChainSize) ;

% Target distribution
targetDist = @(x) mylogpost(This,x) ;

% Construct proposal distribution
propNew = @(x) rwrand(x,chol(initFinalCov)) ;

% This special constant indirectly controls expected tour length:
% higher K means shorter expected tour length
% 
% In the limit as K becomes large the algorithm reduces to a 
% rejection sampling method, and as K becomes small the algorithm
% reduces to pure random walk method. 
K = mean(exp(lp_initSample)) / mean(exp(reentryDist(reentrySample))) ;
ln_K = log(K) ;

% the Alpha state is something out of this world (or at least out of the
% support of Theta...)
alphaState = NaN(nPar,1) ; 
isAlphaState = @(x) all(isnan(x),1) ; % tests which column vectors are NaN

%--------------------------------------------------------------------------
% Main loop
NRegen = NDraw - opt.initialChainSize ;
regenSample = NaN(nPar,NRegen) ;
lp_regenSample = NaN(1,NRegen) ;
Yt = alphaState ; %start in Alpha state
lp_Yt = NaN ;
t = 0 ;
s = 1 ;
len = zeros(1,NRegen) ;
fprintf(1,'Tour     Draw     Avg Tour Length\n') ;
while t < NRegen
    t = t + 1 ;
    lp_V = NaN ;
    lp_Z = NaN ;
    lp_W = NaN ;
    alpha_W = NaN ;
    accZ = false ;
    accV = false ;
    accW = false ;
    
    if isAlphaState( Yt )
        V = alphaState ;
    else
        Z = propNew( Yt ) ;
        lp_Z = targetDist( Z ) ;
        if log(rand) < min([0, lp_Z - lp_Yt]) 
            accZ = true ;
            [V, lp_V] = deal(Z, lp_Z) ;
        else
            [V, lp_V] = deal(Yt, lp_Yt) ;
        end
    end
    if isAlphaState( V )
        W = reentryDist([ ],'draw') ;
        lp_W = targetDist( W ) ;
        lq_W = reentryDist( W ) + ln_K ;
        if log(rand) < min([0, lp_W - lq_W]) ;
            accW = true ;
            [Yt, lp_Yt] = deal(W, lp_W) ;
        else
            [Yt, lp_Yt] = deal(alphaState, NaN) ;
        end
    else
        lq_V = reentryDist( V ) + ln_K ;
        if log(rand) < min([0, lq_V - lp_V])
            accV = true ;
            [Yt, lp_Yt] = deal(V, lp_V) ;
        else
            [Yt, lp_Yt] = deal(alphaState, NaN) ;
        end
    end
    
    if isAlphaState( Yt )
        % don't store alpha states
        t = t-1 ; 
    else
        % increment length of tour s by 1
        len(s) = len(s) + 1 ;
        
        if accW
            % escaped alpha state, new tour
            s = s+1 ;
        end
        
        regenSample(:,t) = Yt ;
        lp_regenSample(t) = lp_Yt ;
    end
    fprintf(1,'%4.f     %4.f     %6.f\n',s,t,mean(len(1:s))) ;
end
len = len(1:s) ;

sample = [initSample regenSample] ;
lp_Sample = [lp_initSample lp_regenSample] ;


    function newTheta = rwrand(theta, sig)
        u = randn(nPar,1) ;
        newTheta = theta + sig*u ;
    end

end
