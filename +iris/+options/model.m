function def = model( )
% model  Default options for model class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

deviation_dtrends = {
    'Deviation, Deviations', false, @islogicalscalar
    'DTrends, DTrend', @auto, @(x) islogicalscalar(x) || isequal(x, @auto)
    };

precision = {
    'precision', 'double', @(x) ischar(x) && any(strcmpi(x, {'double', 'single'}))
    };

matrixFormat = {
    'MatrixFormat', 'namedmat', @namedmat.validateMatrixFormat
    };

select = {
    'select', @all, @(x) (isequal(x, @all) || iscellstr(x) || ischar(x)) && ~isempty(x)
    };

def = struct( );


def.autocaption = { ...
    'corr', 'Corr $shock1$ X $shock2$', @ischar, ...
    'std', 'Std $shock$', @ischar, ...
    };

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

def.fmse = [
    matrixFormat
    select
];


def.fisher = {
    'chksgf', false, @(x) isequal(x, true) || isequal(x, false)
    'ChkSstate', true, @model.validateChksstate
    'Deviation', true, @(x) isequal(x, true) || isequal(x, false)
    'epspower', 1/3, @isnumericscalar
    'exclude', { }, @(x) ischar(x) || iscellstr(x)
    'percent', false, @(x) isequal(x, true) || isequal(x, false)
    'progress', false, @(x) isequal(x, true) || isequal(x, false)
    'Solve', true, @model.validateSolve
    'Steady, sstate, sstateopt', false, @model.validateSstate
    'tolerance', eps( )^(2/3), @isnumericscalar
    };

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
    'NAhead', 0, @(x) isnumeric(x) && isscalar(x) && x>=0 && round(x)==x
    'RescaleVar', false, @(x) isequal(x, true) || isequal(x, false)
    'UnitFromData', @auto, @(x) isequal(x, @auto) || isequal(x, false) || (isintscalar(x) && x>=0)
    };

def.neighbourhood = {
    'plot', true, @(x) isequal(x, true) || isequal(x, false)
    'progress', false, @(x) isequal(x, true) || isequal(x, false)
    'neighbourhood', [ ], @(x) isempty(x) || isstruct(x)
    };

def.regress = [
    matrixFormat
    {
    'acf', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    }
];
    
def.shockplot = { ...
    'dbplot', { }, @(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'Deviation', true, @islogicalscalar, ...
    'DTrends, DTrend', @auto, @(x) islogicalscalar(x) || isequal(x, @auto), ...
    'simulate', { }, @(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'shocksize, size', 'std', @(x) isnumeric(x) ...
    || (ischar(x) && strcmpi(x, 'std')), ...
    };

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


def.lhsmrhs = { ...
    'kind', 'dynamic', @(x) ischar(x) && any(strcmpi(x, {'dynamic', 'steady'})), ...
    };

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
