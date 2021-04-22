function def = model( )
% model  Default options for model class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

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

def.chkmissing = { 
    'error', true, @(x) isequal(x, true) || isequal(x, false)
    };

def.chkredundant = {
    'warning', true, @(x) isequal(x, true) || isequal(x, false)
    'chkshock, chkshocks', true, @(x) isequal(x, true) || isequal(x, false)
    'chkparam, chkparams, chkparameters', true, @(x) isequal(x, true) || isequal(x, false)
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
    'Steady, sstate, sstateopt', false, @model.validateSteady
    'tolerance', eps( )^(2/3), @isnumericscalar
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

def.lognormal = {
    'fresh', false, @islogicalscalar
    'mean', true, @islogicalscalar
    'median', true, @islogicalscalar
    'mode', true, @islogicalscalar
    'prctile, pctile, pct', [5, 95], @(x) isnumeric(x) && all(round(x(:))>0 & round(x(:))<100)
    'prefix', 'lognormal', @(x) ischar(x) && ~isempty(x)
    'std', true, @islogicalscalar
    };

%def.kalman = {
%    'InitMedian', [ ], @(x) isempty(x) || isstruct(x) || strcmpi(x, 'InputData')
%    'NAhead', 0, @(x) isnumeric(x) && isscalar(x) && x>=0 && round(x)==x
%    'RescaleVar', false, @(x) isequal(x, true) || isequal(x, false)
%    'UnitFromData', @auto, @(x) isequal(x, @auto) || isequal(x, false) || (isintscalar(x) && x>=0)
%    };

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


def.VAR = {...
    'acf', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    'order', 1, @isnumericscalar
    'constant, const', true, @(x) isequal(x, true) || isequal(x, false)
    };

def.vma = [
    matrixFormat
    select
    ];

end
