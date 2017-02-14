function def = model( )
% model  Default options for model class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

FN_VALID = irisopt.validfn;

%--------------------------------------------------------------------------

deviation_dtrends = {
    'deviation, deviations', false, @islogicalscalar
    'dtrends, dtrend', @auto, @(x) islogicalscalar(x) || isequal(x, @auto)
    };

precision = {
    'precision', 'double', @(x) ischar(x) && any(strcmpi(x, {'double', 'single'}))
    };

applyfilter = {
    'applyto', @all, @(x) isequal(x, @all) || iscellstr(x)
    'filter', '', @ischar
    };

swap = {
    'endogenize, endogenise', { }, @(x) isempty(x) || iscellstr(x) || ischar(x) || isequal(x, @auto)
    'exogenize, exogenise', { }, @(x) isempty(x) || iscellstr(x) || ischar(x) || isequal(x, @auto)
    };

if true % ##### MOSW
    matrixFmt = {
        'MatrixFmt', 'namedmat', FN_VALID.matrixfmt
        };
else
    matrixFmt = {
        'MatrixFmt', 'plain', validFn.matrixfmt
        }; %#ok<UNRCH>
end

select = {
    'select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x)) && ~isempty(x)
    };

system = {
    'eqtn, equations', @all, @(x) isequal(x, @all) || ischar(x)
    'linear', @auto, @(x) islogicalscalar(x) || isequal(x, @auto)
    'normalize, normalise', true, @islogicalscalar
    'select', true, @islogicalscalar
    'symbolic', true, @islogicalscalar
    };




def = struct( );




def.acf = [
    matrixFmt
    select
    applyfilter
    {
    'acf', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    'nfreq', 256, @isnumericscalar
    'contributions, contribution', false, @islogicalscalar
    'order', 0, @isnumericscalar
    } ];

def.autocaption = { ...
    'corr', 'Corr $shock1$ X $shock2$', @ischar, ...
    'std', 'Std $shock$', @ischar, ...
    };

def.blazer = [
    swap
    {
    'kind', 'steady', @(x) ischar(x) && any(strcmpi(x, {'sstate', 'steady', 'dynamic'}))
    'saveas', '', @ischar
    } ];

def.bn = [
    deviation_dtrends
    ]; %#ok<NBRAK>

def.chkmissing = { ...
    'error', true, @islogicalscalar, ...
    };

def.chkredundant = { ...
    'warning', true, @islogicalscalar, ...
    'chkshock, chkshocks', true, @islogicalscalar, ...
    'chkparam, chkparams, chkparameters', true, @islogicalscalar, ...
    };

def.chksstate = { ...
    'error', true, @islogicalscalar, ...
    'warning', true, @islogicalscalar, ...
    };

def.mychksstate = {
    'Kind, Type, Eqtn, Equation, Equations', 'dynamic', @(x) ischar(x) && any(strcmpi(x, {'dynamic', 'full', 'steady', 'sstate'}))
    };

def.diffloglik = {...
    'chksstate', true, FN_VALID.chksstate, ...
    'progress', false, @islogicalscalar, ...
    'solve', true, FN_VALID.solve, ...
    'sstate, sstateopt', false, FN_VALID.sstate, ...
    };

% Combine model/estimate with shared.Estimation/estimate.
x = irisopt.Estimation( );
def.estimate = [
    matrixFmt
    x.estimate
    {
    'chksstate', true, FN_VALID.chksstate
    'domain', 'time', @(x) any(strncmpi(x, {'t', 'f'}, 1))
    'filter, filteropt', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'nosolution', 'error', @(x) (isnumericscalar(x) && x>=1e10) || (ischar(x) && any(strcmpi(x, {'error', 'penalty'})))
    'solve', true, FN_VALID.solve
    'sstate, sstateopt', false, FN_VALID.sstate
    'zero', false, @islogicalscalar
    } ];

def.fevd = [
    matrixFmt
    select
    ];

def.fmse = [
    matrixFmt
    select
    ];

def.ffrf = [
    matrixFmt
    select
    {
    'include', @all, @(x) isempty(x) || isequal(x, @all) || ischar(x) || iscellstr(x)
    'exclude', { }, @(x) isempty(x) || ischar(x) || iscellstr(x)
    'maxiter', [ ], @(x) isempty(x) || (isnumericscalar(x) && x>=0)
    'tolerance', [ ], @(x) isempty(x) || (isnumericscalar(x) && x>0)
    } ];

def.filter = [
    matrixFmt
    {
    'data, output', 'smooth', @(x) ischar(x)
    } ];

def.fisher = { ...
    'chksgf', false, @islogicalscalar, ...
    'chksstate', true, FN_VALID.chksstate, ...
    'deviation', true, @islogicalscalar, ...
    'epspower', 1/3, @isnumericscalar, ...
    'exclude', { }, @(x) ischar(x) || iscellstr(x), ...
    'percent', false, @islogicalscalar, ...
    'progress', false, @islogicalscalar, ...
    'solve', true, FN_VALID.solve, ...
    'sstate, sstateopt', false, FN_VALID.sstate, ...
    'tolerance', eps( )^(2/3), @isnumericscalar, ...
    };

def.jforecast = [
    deviation_dtrends
    {
    'anticipate', true, @islogicalscalar
    'currentonly', true, @islogicalscalar
    'initcond', 'data', @(x) isnumeric(x) || (ischar(x) && any(strcmpi(x, {'data', 'fixed'})))
    'meanonly', false, @islogicalscalar
    'precision', 'double', @(x) ischar(x) && any(strcmpi(x, {'double', 'single'}))
    'progress', false, @islogicalscalar
    'plan, Scenario', [ ], @(x) isa(x, 'plan') || isa(x, 'Scenario') || isempty(x)
    'vary, std', [ ], @(x) isstruct(x) || isempty(x)
    } ];

def.icrf = {
    'delog', true, @islogicalscalar
    'size', [ ], @(x) isempty(x) || isnumericscalar(x)
    };

def.ifrf = [
    matrixFmt
    select
    ];

def.loglik = [
    matrixFmt
    {
    'domain', 'time', @(x) any(strncmpi(x, {'t', 'f'}, 1))
    'persist', false, @islogicalscalar
    } ];

def.fdlik = [
    deviation_dtrends
    {
    'band', [2, Inf], @(x) isnumeric(x) && length(x)==2
    'exclude', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x)
    'objdecomp, objcont', false, @islogicalscalar
    'outoflik', { }, @(x) ischar(x) || iscellstr(x)
    'relative', true, @islogicalscalar
    'zero', true, @islogicalscalar
    } ];

def.lognormal = {
    'fresh', false, @islogicalscalar
    'mean', true, @islogicalscalar
    'median', true, @islogicalscalar
    'mode', true, @islogicalscalar
    'prctile, pctile, pct', [5, 95], @(x) isnumeric(x) && all(round(x(:))>0 & round(x(:))<100)
    'prefix', 'lognormal', @(x) ischar(x) && ~isempty(x)
    'std', true, @islogicalscalar
    };

def.kalmanFilter = [
    deviation_dtrends
    precision
    {
    'ahead', 1, @(x) isintscalar(x) && x>0
    'chkexact', false, @islogicalscalar
    'chkfmse', false, @islogicalscalar
    'condition', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x)
    'fmsecondtol', eps( ), @(x) isnumericscalar(x) && x>0 && x<1
    'returncont, contributions', false, @islogicalscalar
    'initcond, init', 'stochastic', @(x) isstruct(x) || (ischar(x) && any(strcmpi(x, {'Stochastic', 'Fixed', 'Optimal', 'FixedUnknown'})))
    ... 'InitMeanUnit', 'FixedUnknown', @(x) isstruct(x) || (ischar(x) && any(strcmpi(x, {'FixedUnknown', 'ApproxDiffuse'})))
    'InitUnit', 'FixedUnknown', @(x) ischar(x) && any(strcmpi(x, {'FixedUnknown', 'ApproxDiffuse'}))
    'lastsmooth', Inf, @(x) isempty(x) || isnumericscalar(x)
    ... 'nonlinear, nonlinearise, nonlinearize', 0, @(x) isintscalar(x) && x>=0
    'outoflik', { }, @(x) ischar(x) || iscellstr(x)
    'objdecomp', false, @islogicalscalar
    'objfunc, objective', 'loglik', @(x) ischar(x) && any(strcmpi(x, {'loglik', 'mloglik', '-loglik', 'prederr'}))
    'objrange, objectivesample', @all, @(x) isnumeric(x) || isequal(x, @all)
    'pedindonly', false, @islogicalscalar
    'plan, Scenario', [ ], @(x) isa(x, 'plan') || isa(x, 'Scenario') || isempty(x)
    'progress', false, @islogicalscalar
    'relative', true, @islogicalscalar
    'vary, std', [ ], @(x) isempty(x) || isstruct(x)
    'simulate', false, @(x) isequal(x, false) || (iscell(x) && iscellstr(x(1:2:end)))
    'symmetric', true, @islogicalscalar
    'tolerance', eps( )^(2/3), @isnumeric
    'tolmse', 0, @(x) isnumericscalar(x) || (ischar(x) && strcmpi(x, 'auto'))
    'weighting', [ ], @isnumeric
    'meanonly', false, @islogicalscalar
    'returnstd', true, @islogicalscalar
    'returnmse', true, @islogicalscalar
    } ];

def.kalman = {
    'InitMedian', [ ], @(x) isempty(x) || isstruct(x) || strcmpi(x, 'InputData')
    'NAhead', 0, @(x) isnumericscalar(x) && x>=0 && round(x)==x
    'RescaleVar', false, @islogicalscalar
    'UnitFromData', @auto, @(x) isequal(x, @auto) || isequal(x, false) || (isintscalar(x) && x>=0)
    };

x = irisopt.theparser( );
def.model = [
    x.parse
    {
    'addlead', false, @islogicalscalar
    'Assign', [ ], @(x) isempty(x) || isstruct(x)
    'chksyntax', true, @islogicalscalar
    'comment', '', @ischar
    'optimal', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'epsilon', [ ], @(x) isempty(x) || (isnumericscalar(x) && x>0 && x<1)
    'removeleads, removelead', false, @islogicalscalar
    'linear', false, @islogicalscalar
    'makebkw', @auto, @(x) isequal(x, @auto) || isequal(x, @all) || iscellstr(x) || ischar(x)
    'OrderLinks', true, @islogicalscalar
    'precision', 'double', @(x) ischar(x) && any(strcmp(x, {'double', 'single'}))
    'Refresh', true, @islogicalscalar 
    'quadratic', false, @islogicalscalar
    'saveas', '', @ischar
    'symbdiff, symbolicdiff', true, @(x) islogicalscalar(x) || ( iscell(x) && iscellstr(x(1:2:end)) )
    'std', @auto, @(x) isequal(x, @auto) || (isnumericscalar(x) && x>=0)
    'stdlinear', model.DEFAULT_STD_LINEAR, @(x) isnumericscalar(x) && x>=0
    'stdnonlinear', model.DEFAULT_STD_NONLINEAR, @(x) isnumericscalar(x) && x>=0
    'baseyear, torigin', @config, @(x) isequal(x, @config) || isempty(x) || isintscalar(x)
    } ];

def.neighbourhood = {
    'plot', true, @islogicalscalar
    'progress', false, @islogicalscalar
    'neighbourhood', [ ], @(x) isempty(x) || isstruct(x)
    };

def.optimal = {
    'multiplierprefix', 'Mu_', @ischar
    'nonnegative', { }, @(x) isempty(x) || ( ischar(x) && isvarname(x) )
    'type', 'discretion', @(x) ischar(x) && any(strcmpi(x, {'consistent', 'commitment', 'discretion'}))
    };

def.regress = [
    matrixFmt
    {
    'acf', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    } ];
    
def.resample = [
    deviation_dtrends
    {
    'bootstrapMethod', 'efron', @(x) (ischar(x) && any(strcmpi(x, {'efron', 'wild'}))) || isintscalar(x) || isnumericscalar(x, 0, 1)
    'method', 'montecarlo', @(x) isfunc(x) || (ischar(x) && any(strcmpi(x, {'montecarlo', 'bootstrap'})))
    'progress', false, @islogicalscalar
    'randominitcond, randomiseinitcond, randomizeinitcond, randomise, randomize', true, @(x) islogicalscalar(x) || (isnumericscalar(x) && x>=0)
    'svdonly', false, @islogicalscalar
    'statevector', 'alpha', @(x) ischar(x) && any(strcmpi(x, {'alpha', 'x'}))
    'vary', [ ], @(x) isempty(x) || isstruct(x)
    'wild', [ ], @(x) isempty(x) || islogicalscalar(x)
    } ];

def.shockplot = { ...
    'dbplot', { }, @(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'deviation', true, @islogicalscalar, ...
    'dtrends, dtrend', @auto, @(x) islogicalscalar(x) || isequal(x, @auto), ...
    'simulate', { }, @(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'shocksize, size', 'std', @(x) isnumeric(x) ...
    || (ischar(x) && strcmpi(x, 'std')), ...
    };




def.simulate = [
    deviation_dtrends
    {
    'anticipate', true, @islogicalscalar
    'Presample, AddPresample', false, @islogical
    'contributions, contribution', false, @islogicalscalar
    'dboverlay, dbextend', false, @(x) islogicalscalar(x) || isstruct(x)
    'Delog', true, @islogicalscalar
    'fast', true, @islogicalscalar
    'ignoreshocks, ignoreshock, ignoreresiduals, ignoreresidual', false, @islogicalscalar
    'method', 'firstorder', @(x) ischar(x) && any(strcmpi(x, {'firstorder', 'selective', 'global', 'exact'}))
    'missing', NaN, @isnumeric
    'plan, Scenario', [ ], @(x) isa(x, 'plan') || isa(x, 'Scenario') || isempty(x)
    'progress', false, @islogicalscalar
    'sparseshocks, sparseshock', false, @islogicalscalar
    'Revision, Revisions', false, @islogicalscalar
    ...
    ... Bkw compatibility
    ...
    'nonlinear, nonlinearize, nonlinearise', [ ], @(x) isempty(x) || isnumeric(x) || isequal(x, @all)
    ...
    ... Nonlinear simulations
    ...
    'display', @auto, FN_VALID.Display
    'error', false, @islogicalscalar
    'Gradient', true, @islogicalscalar
    'optimset', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x)
    'Solver', @auto, @(x) isequal(x, @auto) ...
    || (ischar(x) && any(strcmpi(x, {'qad', 'plain', 'lsqnonlin', 'IRIS', 'fsolve'}))) ...
    || isequal(x, @fsolve) || isequal(x, @lsqnonlin) || isequal(x, @qad) ...
    || ( iscell(x) && iscellstr(x(2:2:end)) )
    ...
    ... Equation-selective simulations
    ...
    'NonlinWindow, nonlinper', @all, @(x) isequal(x, @all) || (isintscalar(x) && x>=0)
    'maxnumeljv', 1e6, @(x) isintscalar(x) && x>=0
    ...
    ... Equation-selective nonlinear simulations - QaD
    ...
    'addsstate', true, @islogicalscalar
    'fillout', false, @islogicalscalar
    'lambda', 1, @(x) isnumericscalar(x) && all(x>0 & x<=2)
    'noptimlambda, optimlambda', 1, @(x) islogicalscalar(x) || (isintscalar(x) && x>=0)
    'reducelambda, lambdafactor', 0.5, @(x) isnumericscalar(x) && x>0 && x<=1
    'maxiter', 100, @isnumericscalar
    'nshanks', false, @(x) isempty(x) || (isintscalar(x) && x>0) || isequal(x, false)
    'tolerance', 1e-5, @isnumericscalar
    'upperbound', 1.5, @(x) isnumericscalar(x) && all(x>1)
    ...
    ... Equation-selective nonlinear simulations - Optim Tbx
    ...
    'optimset', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x)
    ...
    ... Global nonlinear simulations
    ...
    'AlmostLinear', false, @islogicalscalar
    'chksstate', true, FN_VALID.chksstate
    'ForceRediff', false, @islogicalscalar
    'InitEndog', 'Dynamic', @(x) ischar(x) && any(strcmpi(x, {'Dynamic', 'Static'})) 
    'solve', true, FN_VALID.solve
    'sstate, sstateopt', true, FN_VALID.sstate
    'Unlog', [ ], @(x) isempty(x) || isequal(x, @all) || iscellstr(x) || ischar(x)
    'times', @auto, @(x) isequal(x, @auto) || ( isnumericscalar(x) && x>0 )
    'whenfailed', 'warning', @(x) ischar(x) && any(strcmpi(x, {'error', 'warning'}))
    } ];

def.solve = [
    system
    {
    'expand, forward', 0, @(x) isnumeric(x) && length(x)==1
    'fast', false, @islogicalscalar
    'error', false, @islogicalscalar
    'progress', false, @islogicalscalar
    'warning', true, @islogicalscalar
    } ];

def.symbdiff = { ...
    'simplify', true, @islogicalscalar, ...
    };

def.createSourceDbase = [
    deviation_dtrends
    {
    'AppendPresample, AddPresample', true, @islogicalscalar
    'AppendPostsample, AddPostsample', false, @islogicalscalar
    'ndraw', 1, @(x) isintscalar(x) && x>=0
    'ncol', 1, @(x) isintscalar(x) && x>=0
    'randshocks, randshock, randomshocks, randomshock', false, @islogicalscalar
    'shockfunc, randfunc, randfn', @zeros, @(x) isa(x, 'function_handle') && any(strcmp(func2str(x), {'randn', 'lhsnorm', 'zeros'}))
    } ];

def.srf = [
    select
    {
    'delog, log', true, @islogicalscalar
    'size', @auto, @(x) isequal(x, @auto) || isnumericscalar(x)
    } ];

def.sspace = {
    'triangular', true, @islogicalscalar
    'removeinactive', false, @islogicalscalar
    };




def.Steady = {
    'Linear', @auto, @(x) islogicalscalar(x) || isequal(x, @auto)
    };




def.SteadyLinear = {
    'Solve', false, FN_VALID.solve
    'Warning', true, @islogicalscalar
    };




def.SteadyNonlinear = [
    swap
    {
    'AlmostLinear', false, @islogicalscalar
    'blocks, block', true, @islogicalscalar
    'fix', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'fixallbut', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'fixlevel', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'fixlevelallbut', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'fixgrowth', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'fixgrowthallbut', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'ForceRediff', false, @islogicalscalar
    'growth', false, @islogicalscalar
    'growthbounds, growthbnds', [ ], @(x) isempty(x) || isstruct(x)
    'levelbounds, levelbnds', [ ], @(x) isempty(x) || isstruct(x)
    ... 'LogMinus', { }, @(x) isempty(x) || ischar(x) || iscellstr(x) || isequal(x, @all)
    'optimset', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x)
    'NanInit, init', 1, @(x) isnumericscalar(x) && isfinite(x)
    'resetinit', [ ], @(x) isempty(x) || (isnumericscalar(x) && isfinite(x))
    'Reuse', false, @islogicalscalar
    'Solver', 'IRIS', @(x) ischar(x) || isa(x, 'function_handle') || (iscell(x) && iscellstr(x(2:2:end)) && (ischar(x{1}) || isa(x{1}, 'function_handle')))
    'Gradient', true, @islogicalscalar
    'Unlog', { }, @(x) isempty(x) || ischar(x) || iscellstr(x) || isequal(x, @all)
    'Warning', true, @islogicalscalar
    'zeromultipliers', false, @islogicalscalar
    } ];




def.lhsmrhs = { ...
    'kind', 'dynamic', @(x) ischar(x) && any(strcmpi(x, {'dynamic', 'steady'})), ...
    };

def.shockdb = { ...
    'shockfunc, randfunc, randfn', @zeros, ...
    @(x) isa(x, 'function_handle') ...
    && any(strcmp(func2str(x), {'randn', 'lhsnorm', 'zeros'})), ...
    };

def.sstatefile = [
    swap
    {
    'growthnames, growthname', 'd?', @ischar
    'time', true, @islogicalscalar
    } ];

def.system = [
    system
    {
    'sparse', false, @islogicalscalar
    } ];

def.trollify = { 
    'SrcTemplate', 'trollify_template.src', @ischar
    'InpTemplate', 'trollify_template.inp', @ischar
    'InpFileName', 'StartVals.inp', @ischar
    'ModelName', @auto, @(x) isequal(x, @auto) || ischar(x)
    'ParametersAs=', 'Exogenous', @(x) ischar(x) && any(strcmpi(x, {'Parameters', 'Exogenous'}))
    'SteadyRefSuffix', 'SS', @ischar
    };

def.VAR = {...
    'acf', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    'order', 1, @isnumericscalar
    'constant, const', true, @islogicalscalar
    };

def.vma = [
    matrixFmt
    select
    ];

def.xsf = [
    applyfilter
    matrixFmt
   	select
    {
    'progress', false, @islogicalscalar, ...
    } ];

end
