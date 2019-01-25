function def = VAR( )
% VAR  Default options for VAR class functions
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

def = struct( );

outputFmt = {
    'output', 'auto', @(x) any(strcmpi(x, {'auto', 'dbase', 'tseries', 'array'}))
};


matrixFormat = {
    'MatrixFormat', 'namedmat', @namedmat.validateMatrixFormat
};


applyFilter = { 
    'ApplyTo', @all, @(x) isnumeric(x) || islogical(x) || isequal(x, @all) || iscellstr(x)
    'Filter', '', @ischar
};


tolerance = {
    'tolerance', getrealsmall( ), @isnumericscalar
};


def.acf = [
    applyFilter
    matrixFormat
    {
    'NFreq', 256, @isnumericscalar
    'Order', 0, @isnumericscalar
    'Progress', false, @islogicalscalar
    }; %#ok<*CCAT>
];


def.estimate = {
    'a', [ ], @isnumeric
    'bvar', [ ], @(x) isempty(x) || isa(x, 'BVAR.bvarobj')
    'c', [ ], @isnumeric    
    'j', [ ], @isnumeric
    'diff', false, @islogicalscalar
    'g', [ ], @isnumeric
    'order', 1, @(x) isnumeric(x) && numel(1) == 1
    'cointeg', [ ], @isnumeric
    'comment', '', @(x) ischar(x) || isequal(x, Inf)
    'constraints, constraint', '', @(x) ischar(x) || iscellstr(x) || isnumeric(x)
    'constant, const, constants', true, @islogicalscalar
    'covparameters, covparameter, covparam', false, @islogicalscalar
    'eqtnbyeqtn', false, @islogicalscalar
    'MaxIter', 1, @isnumericscalar
    'mean', [ ], @(x) isempty(x) || isnumeric(x)
    'progress', false, @islogicalscalar
    'schur', true, @islogicalscalar
    'stdize', false, @islogicalscalar
    'tolerance', 1e-5, @isnumericscalar
    'timeweights', [ ], @(x) isempty(x) || isa(x, 'tseries')
    'ynames, yname', { }, @iscellstr
    'warning', true, @islogicalscalar
    ... Panel VARs
    'fixedeff, fixedeffect', true, @islogicalscalar
    'groupweights', [ ], @(x) isempty(x) || isnumeric(x)
    'groupspec', false, @(x) islogicalscalar(x) || iscellstr(x) || ischar(x)
};


def.filter = {
    'ahead', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1
    'cross', true, @(x) (islogical(x) && isscalar(x)) || (isnumeric(x) && isscalar(x) && x>=0 && x<=1)
    'Deviation, Deviations', false, @(x) islogical(x) && isscalar(x)
    'meanonly', false, @(x) islogical(x) && isscalar(x)
    'omega', [ ], @isnumeric
    'output', 'smooth', @ischar    
};

def.fmse = [
    matrixFormat
]; %#ok<CCAT1>

def.forecast = [
    outputFmt
    {
    'cross', true, @(x) islogicalscalar(x) || (isnumericscalar(x) && x >=0 && x <= 1)
    'dboverlay, dbextend', false, @islogicalscalar
    'Deviation, Deviations', false, @islogicalscalar
    'meanonly', false, @islogicalscalar
    'omega', [ ], @isnumeric
    'returninstruments, returninstrument', true, @islogicalscalar
    'returnresiduals, returnresidual', true, @islogicalscalar
    'E', [ ], @(x) isempty(x) || isnumeric(x) 
    'Sigma', [ ], @isnumeric
    }
];

def.integrate = {
    'applyto', Inf, @(x) isnumeric(x) || islogical(x)
    };

def.isexplosive = [
    tolerance
]; %#ok<CCAT1>

def.isstationary = [
    tolerance
]; %#ok<CCAT1>


def.portest = {
    'level', 0.05, @(x) isnumericscalar(x) && x > 0 && x < 1
    };

def.resample = [
    outputFmt
    {
    'Deviation, Deviations', false, @islogicalscalar   
    'method', 'montecarlo', @(x) isfunc(x) ...
    || (ischar(x) && any(strcmpi(x, {'montecarlo', 'bootstrap'})))
    'progress', false, @islogicalscalar
    'randomise, randomize', false, @islogicalscalar
    'wild', false, @islogicalscalar
    }
];

def.sprintf = {
    'constant, constants, const', true, @islogicalscalar
    'decimal', [ ], @(x) isempty(x) || isnumericscalar(x)
    'declare', false, @islogicalscalar
    'enames, ename', [ ], @(x) isempty(x) || iscellstr(x) || isfunc(x)
    'format', '%+.16g', @ischar
    'hardparameters, hardparameter', true, @islogicalscalar
    'tolerance', getrealsmall( ), @isnumericscalar
    'ynames, yname', [ ], @(x) isempty(x) || iscellstr(x)
    };

def.response = {
    'presample', false, @islogicalscalar
    'select', Inf, @(x) isequal(x, Inf) || islogical(x) || isnumeric(x) || ischar(x) || iscellstr(x)
    };

def.VAR = {
    'exogenous', { }, @(x) ischar(x) || iscellstr(x)
    };

end
