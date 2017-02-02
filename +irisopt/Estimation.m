function def = Estimation( )
% Estimation  Default options for Estimation class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

def.estimate = {
    'display', 'iter', @(x) isanystri(x, {'iter', 'final', 'none', 'off'})
    'epspower', 1/2, @isnumeric
    'initval', 'struct', @(x) isempty(x) || isstruct(x) || isanystri(x, {'struct', 'model'})
    'maxiter', 500, @(x) isnumericscalar(x) && x>=0
    'maxfunevals', 2000, @(x) isnumericscalar(x) && x>0
    'optimset', { }, @(x) isempty(x) || isstruct(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'penalty', 0, @(x) isnumericscalar(x) && x>=0
    'evallik', true, @islogicalscalar
    'evalpprior, evalppriors', true, @islogicalscalar
    'evalsprior, evalspriors', true, @islogicalscalar
    'solver, optimiser, optimizer', 'fmin', ...
    @(x) (ischar(x) && any(strcmpi(x, {'fmin', 'lsqnonlin', 'pso', 'alps'}))) ...
    || iscell(x) || isfunc(x)
    'tolfun', 1e-6, @(x) isnumeric(x) && x>0
    'tolx', 1e-6, @(x) isnumeric(x) && x>0
    'updateinit', [ ], @(x) isempty(x) || isstruct(x)
    };

end
