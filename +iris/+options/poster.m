function def = poster( )
% poster  Default options for poster class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%#ok<*CCAT>

%--------------------------------------------------------------------------

def = struct( );

def.arwm = {
    'adaptscale', 1, @(x) isnumericscalar(x) && x >= 0
    'adaptproposalcov', 0.5, @(x) isnumericscalar(x) && x >= 0
    'burnin', 0.10, @(x) isnumeric(x) && isscalar(x)  && ( (x>=0 && x<1) || (x>1 && x==round(x)) )
    'firstPrefetch, firstParallel', 1, @isintscalar
    'gamma', 0.8, @(x) isnumericscalar(x) && ( (x > 0.5 && x <= 1) || isnan(x) || isinf(x) )
    'initscale', @auto, @(x) isequal(x, @auto) || (isnumericscalar(x) && x > 0)
    'lastadapt', Inf, @isintscalar
    'progress', false, @islogicalscalar
    'saveevery', Inf, @(x) isintscalar(x) && x > 0
    'saveas', '', @ischar
    'targetar', 0.234, @(x) isnumericscalar(x) && x > 0 && x <= 0.5
	'nstep, nsteps', 1, @(x) isintscalar(x) && x>0
};

def.impsamp = {
    'progress', false, @islogicalscalar
};

def.regen = {
    'initialChainSize', 0.1, @(x) isnumericscalar(x) && x > 0
};

def.stats = {
    'hpdicover', 90, @(x) isnumericscalar(x) && x >= 0 && x <= 100
    'histbins, histbin', 50, @(x) isintscalar(x) && x > 0
    'mddgrid', 0.1:0.1:0.9, @(x) isnumeric(x) && all(x(:) > 0 & x(:) < 1)
    'output', '', @(x) ischar(x) || iscellstr(x)
    'progress', false, @islogicalscalar
    ...
    'chain', true, @islogicalscalar
    'cov', false, @islogicalscalar
    'mean', true, @islogicalscalar
    'median', false, @islogicalscalar
    'mode', false, @islogicalscalar
    'mdd, lmdd', true, @islogicalscalar
    'std', true, @islogicalscalar
    'hpdi', false, @(x) islogicalscalar(x) || (isnumericscalar(x) && x > 0 && x < 100)
    'hist', true, @(x) islogicalscalar(x) || (isintscalar(x) && x > 0)
    'bounds', false, @islogicalscalar
    'ksdensity', false, @(x) islogicalscalar(x) || isempty(x) || (isintscalar(x) && x > 0)
    'prctile, pctile', [ ], @(x) isnumeric(x) && all(x(:) >= 0 & x(:) <= 100)
};

end
