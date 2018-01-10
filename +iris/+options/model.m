function def = model( )
% model  Default options for model class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

FN_VALID = iris.options.validfn;

%--------------------------------------------------------------------------

deviation_dtrends = {
    'deviation, deviations', false, @islogicalscalar
    'dtrends, dtrend', @auto, @(x) islogicalscalar(x) || isequal(x, @auto)
    };

precision = {
    'precision', 'double', @(x) ischar(x) && any(strcmpi(x, {'double', 'single'}))
    };

swap = {
    'endogenize, endogenise', { }, @(x) isempty(x) || iscellstr(x) || ischar(x) || isequal(x, @auto)
    'exogenize, exogenise', { }, @(x) isempty(x) || iscellstr(x) || ischar(x) || isequal(x, @auto)
};

matrixFormat = {
    'MatrixFormat', 'namedmat', @namedmat.validateMatrixFormat
    };

select = {
    'select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x)) && ~isempty(x)
    };

system = {
    'eqtn, equations', @all, @(x) isequal(x, @all) || ischar(x)
    'normalize, normalise', true, @islogicalscalar
    'select', true, @islogicalscalar
    'symbolic', true, @islogicalscalar
    };


def = struct( );


def.autocaption = { ...
    'corr', 'Corr $shock1$ X $shock2$', @ischar, ...
    'std', 'Std $shock$', @ischar, ...
    };

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

def.chksstate = { 
    'error', true, @(x) isequal(x, true) || isequal(x, false)
    'warning', true, @(x) isequal(x, true) || isequal(x, false)
};

def.mychksstate = {
    'Kind, Type, Eqtn, Equation, Equations', 'dynamic', @(x) ischar(x) && any(strcmpi(x, {'dynamic', 'full', 'steady', 'sstate'}))
    };

def.diffloglik = {
    'ChkSstate', true, @model.validateChksstate
    'progress', false, @(x) isequal(x, true) || isequal(x, false)
    'Solve', true, @model.validateSolve
    'Steady, sstate, sstateopt', false, @model.validateSstate
    };

def.fevd = [
    matrixFormat
    select
];

def.fmse = [
    matrixFormat
    select
];

def.filter = [
    matrixFormat
    {
        'data, output', 'smooth', @(x) ischar(x)
        'Rename', cell.empty(1, 0), @(x) iscellstr(x) || ischar(x) || isa(x, 'string')
    } 
];

def.fisher = {
    'chksgf', false, @(x) isequal(x, true) || isequal(x, false)
    'ChkSstate', true, @model.validateChksstate
    'deviation', true, @(x) isequal(x, true) || isequal(x, false)
    'epspower', 1/3, @isnumericscalar
    'exclude', { }, @(x) ischar(x) || iscellstr(x)
    'percent', false, @(x) isequal(x, true) || isequal(x, false)
    'progress', false, @(x) isequal(x, true) || isequal(x, false)
    'Solve', true, @model.validateSolve
    'Steady, sstate, sstateopt', false, @model.validateSstate
    'tolerance', eps( )^(2/3), @isnumericscalar
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
    'StdScale', complex(1, 0), @(x) (isnumericscalar(x) && real(x)>=0 && imag(x)>=0 && abs(abs(x)-1)<1e-12) || strcmpi(x, 'normalize')
    'vary, std', [ ], @(x) isstruct(x) || isempty(x)
    }
];

def.icrf = {
    'delog', true, @islogicalscalar
    'size', [ ], @(x) isempty(x) || isnumericscalar(x)
    };

def.ifrf = [
    matrixFormat
    select
    ];

def.loglik = [
    matrixFormat
    {
    'domain', 'time', @(x) any(strncmpi(x, {'t', 'f'}, 1))
    'persist', false, @islogicalscalar
    }
];

def.fdlik = [
    deviation_dtrends
    {
    'band', [2, Inf], @(x) isnumeric(x) && length(x)==2
    'exclude', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x)
    'objdecomp, objcont', false, @islogicalscalar
    'outoflik', { }, @(x) ischar(x) || iscellstr(x)
    'relative', true, @islogicalscalar
    'zero', true, @islogicalscalar
    }
];

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
    'Rolling', false, @(x) isequal(x, false) || isa(x, 'DateWrapper')
    'Init, InitCond', 'Steady', @(x) isstruct(x) || (ischar(x) && any(strcmpi(x, {'Asymptotic', 'Stochastic', 'Steady', 'Fixed'})))
    'InitUnitRoot, InitUnit, InitMeanUnit', 'FixedUnknown', @(x) isstruct(x) || (ischar(x) && any(strcmpi(x, {'FixedUnknown', 'ApproxDiffuse'})))
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
    }
];

def.kalman = {
    'InitMedian', [ ], @(x) isempty(x) || isstruct(x) || strcmpi(x, 'InputData')
    'NAhead', 0, @(x) isnumericscalar(x) && x>=0 && round(x)==x
    'RescaleVar', false, @islogicalscalar
    'UnitFromData', @auto, @(x) isequal(x, @auto) || isequal(x, false) || (isintscalar(x) && x>=0)
    };

def.neighbourhood = {
    'plot', true, @islogicalscalar
    'progress', false, @islogicalscalar
    'neighbourhood', [ ], @(x) isempty(x) || isstruct(x)
    };

def.regress = [
    matrixFormat
    {
    'acf', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    }
];
    
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
    }
];

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
    'AppendPresample, AddPresample', false, @islogical
    'Blocks', true, @islogicalscalar
    'contributions, contribution', false, @islogicalscalar
    'DbOverlay, DbExtend', false, @(x) islogicalscalar(x) || isstruct(x)
    'Delog', true, @islogicalscalar
    'fast', true, @islogicalscalar
    'FOTC', true, @(x) isequal(x, true) || isequal(x, false)
    'ignoreshocks, ignoreshock, ignoreresiduals, ignoreresidual', false, @islogicalscalar
    'Method', 'FirstOrder', @(x) ischar(x) && any(strcmpi(x, {'FirstOrder', 'Selective', 'Global', 'Exact', 'Stacked'}))
    'missing', NaN, @isnumeric
    'plan, Scenario', [ ], @(x) isa(x, 'plan') || isa(x, 'Scenario') || isempty(x)
    'progress', false, @islogicalscalar
    'sparseshocks, sparseshock', false, @islogicalscalar
    'Revision, Revisions', false, @islogicalscalar
    'SystemProperty', false, @(x) isequal(x, true) || isequal(x, false)
    ...
    ... Bkw compatibility
    ...
    'nonlinear, nonlinearize, nonlinearise', [ ], @(x) isempty(x) || isnumeric(x) || isequal(x, @all)
    ...
    ... Stacked time
    ...
    'Stacked', 1, @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>=1
    ...
    ... Nonlinear simulations
    ...
    'Display', @auto, FN_VALID.Display
    'error', false, @islogicalscalar
    'PrepareGradient', @auto, @(x) islogicalscalar(x) || isequal(x, @auto)
    'OptimSet', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x)
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
    'MaxIter', 100, @isnumericscalar
    'nshanks', false, @(x) isempty(x) || (isintscalar(x) && x>0) || isequal(x, false)
    'tolerance', 1e-5, @isnumericscalar
    'upperbound', 1.5, @(x) isnumericscalar(x) && all(x>1)
    ...
    ... Equation-selective nonlinear simulations - Optim Tbx
    ...
    'OptimSet', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x)
    ...
    ... Global nonlinear simulations
    ...
    'ChkSstate', true, @model.validateChksstate
    'ForceRediff', false, @islogicalscalar
    'InitEndog', 'Dynamic', @(x) ischar(x) && any(strcmpi(x, {'Dynamic', 'Static'})) 
    'Solve', true, @model.validateSolve
    'Steady, sstate, sstateopt', true, @model.validateSstate
    'Unlog', [ ], @(x) isempty(x) || isequal(x, @all) || iscellstr(x) || ischar(x)
    'times', @auto, @(x) isequal(x, @auto) || ( isnumericscalar(x) && x>0 )
    'whenfailed', 'warning', @(x) ischar(x) && any(strcmpi(x, {'error', 'warning'}))
    }
];

def.solve = [
    system
    {
    'error', false, @islogicalscalar
    'expand, forward', 0, @(x) isnumeric(x) && length(x)==1
    'fast', false, @islogicalscalar
    'progress', false, @islogicalscalar
    'warning', true, @islogicalscalar
    }
];

def.symbdiff = { ...
    'simplify', true, @islogicalscalar, ...
    };

def.createSourceDbase = [
    deviation_dtrends
    {
    'AppendPresample, AddPresample', true, @islogicalscalar
    'AppendPostsample, AddPostsample', true, @islogicalscalar
    'ndraw', 1, @(x) isintscalar(x) && x>=0
    'ncol', 1, @(x) isintscalar(x) && x>=0
    'randshocks, randshock, randomshocks, randomshock', false, @islogicalscalar
    'shockfunc, randfunc, randfn', @zeros, @(x) isa(x, 'function_handle') && any(strcmp(func2str(x), {'randn', 'lhsnorm', 'zeros'}))
    }
];

def.srf = [
    select
    {
    'delog, log', true, @islogicalscalar
    'size', @auto, @(x) isequal(x, @auto) || isnumericscalar(x)
    }
];

def.sspace = {
    'triangular', true, @islogicalscalar
    'removeinactive', false, @islogicalscalar
    };


def.SteadyLinear = {
    'Solve', false, @model.validateSolve
    'Warning', true, @islogicalscalar
    };


def.SteadyNonlinear = [
    swap
    {
    'blocks, block', true, @islogicalscalar
    'fix', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'fixallbut', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'fixlevel', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'fixlevelallbut', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'fixgrowth', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'fixgrowthallbut', { }, @(x) isempty(x) || iscellstr(x) || ischar(x)
    'ForceRediff', false, @islogicalscalar
    'Growth', @auto, @(x) isequal(x, @auto) || islogicalscalar(x)
    'growthbounds, growthbnds', [ ], @(x) isempty(x) || isstruct(x)
    'levelbounds, levelbnds', [ ], @(x) isempty(x) || isstruct(x)
    ... 'LogMinus', { }, @(x) isempty(x) || ischar(x) || iscellstr(x) || isequal(x, @all)
    'OptimSet', { }, @(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))) || isstruct(x)
    'NanInit, init', 1, @(x) isnumericscalar(x) && isfinite(x)
    'resetinit', [ ], @(x) isempty(x) || (isnumericscalar(x) && isfinite(x))
    'Reuse', false, @islogicalscalar
    'Solver', 'IRIS', @(x) ischar(x) || isa(x, 'function_handle') || (iscell(x) && iscellstr(x(2:2:end)) && (ischar(x{1}) || isa(x{1}, 'function_handle')))
    'PrepareGradient', @auto, @(x) islogicalscalar(x) || isequal(x, @auto)
    'Unlog', { }, @(x) isempty(x) || ischar(x) || iscellstr(x) || isequal(x, @all)
    'Warning', true, @islogicalscalar
    'zeromultipliers', false, @islogicalscalar
    }
];




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
    }
];

def.system = [
    system
    {
    'sparse', false, @islogicalscalar
    }
];

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
    matrixFormat
    select
    ];

end
